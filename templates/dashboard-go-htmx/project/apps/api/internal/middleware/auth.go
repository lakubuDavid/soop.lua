package middleware

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"time"

	"@@MODULE@@/apps/api/internal/repository"
)

type contextKey string

const userKey contextKey = "current-user"
const sessionCookie = "app_session"

type Auth struct {
	repo *repository.Repository
	secret string
	ttl time.Duration
}

func NewAuth(repo *repository.Repository, secret string, ttlHours int64) *Auth {
	return &Auth{repo: repo, secret: secret, ttl: time.Duration(ttlHours) * time.Hour}
}

func (a *Auth) Require(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cookie, err := r.Cookie(sessionCookie)
		if err != nil || cookie.Value == "" {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		user, err := a.repo.FindUserBySession(r.Context(), hashToken(cookie.Value))
		if err != nil {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), userKey, user)))
	})
}

func UserFromContext(ctx context.Context) (repository.User, bool) {
	user, ok := ctx.Value(userKey).(repository.User)
	return user, ok
}

type Session struct {
	Token string
	ExpiresAt time.Time
}

func (a *Auth) CreateSession(ctx context.Context, userID string, r *http.Request) (Session, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil { return Session{}, err }
	token := hex.EncodeToString(bytes)
	expires := time.Now().Add(a.ttl)
	err := a.repo.CreateSession(ctx, userID, hashToken(token), expires, r.UserAgent(), r.RemoteAddr)
	return Session{Token: token, ExpiresAt: expires}, err
}

func (a *Auth) SetCookie(w http.ResponseWriter, session Session) {
	http.SetCookie(w, &http.Cookie{Name: sessionCookie, Value: session.Token, Path: "/", HttpOnly: true, SameSite: http.SameSiteLaxMode, Expires: session.ExpiresAt})
}

func (a *Auth) Logout(w http.ResponseWriter, r *http.Request) {
	if cookie, err := r.Cookie(sessionCookie); err == nil { _ = a.repo.RevokeSession(r.Context(), hashToken(cookie.Value)) }
	http.SetCookie(w, &http.Cookie{Name: sessionCookie, Value: "", Path: "/", MaxAge: -1, HttpOnly: true, SameSite: http.SameSiteLaxMode})
	w.WriteHeader(http.StatusNoContent)
}

func hashToken(token string) string { sum := sha256.Sum256([]byte(token)); return hex.EncodeToString(sum[:]) }
