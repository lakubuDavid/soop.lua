package repository

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

type Repository struct { db *sql.DB; driver string }

func New(db *sql.DB, driver string) *Repository { return &Repository{db: db, driver: driver} }

// bind converts portable ? placeholders to PostgreSQL $N placeholders.
// The template keeps application-owned auth queries small and portable; new
// domain queries should be added to db/<driver>/queries and generated with sqlc.
func (r *Repository) bind(query string) string {
	if r.driver != "postgres" { return query }
	var out strings.Builder
	index := 0
	for _, char := range query {
		if char == '?' { index++; out.WriteString(fmt.Sprintf("$%d", index)) } else { out.WriteRune(char) }
	}
	return out.String()
}

type User struct {
	ID string `json:"id"`
	Email string `json:"email"`
	FirstName string `json:"first_name"`
	LastName string `json:"last_name"`
	DisplayName string `json:"display_name"`
	Status string `json:"status"`
	CreatedAt time.Time `json:"created_at"`
}

func newID() string { b := make([]byte, 16); _, _ = rand.Read(b); return hex.EncodeToString(b) }

func (r *Repository) CreateUser(ctx context.Context, email, password, firstName, lastName string) (User, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil { return User{}, err }
	now := time.Now().UTC()
	user := User{ID: newID(), Email: email, FirstName: firstName, LastName: lastName, DisplayName: strings.TrimSpace(firstName + " " + lastName), Status: "active", CreatedAt: now}
	_, err = r.db.ExecContext(ctx, r.bind(`INSERT INTO users (id, email, email_normalized, password_hash, first_name, last_name, display_name, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`), user.ID, email, strings.ToLower(email), string(hash), firstName, lastName, user.DisplayName, user.Status, now, now)
	return user, err
}

func (r *Repository) FindUserByEmail(ctx context.Context, email string) (User, error) {
	var user User
	err := r.db.QueryRowContext(ctx, r.bind(`SELECT id, email, first_name, last_name, display_name, status, created_at FROM users WHERE email_normalized = ? AND deleted_at IS NULL`), strings.ToLower(email)).Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.DisplayName, &user.Status, &user.CreatedAt)
	return user, err
}

func (r *Repository) FindUserBySession(ctx context.Context, tokenHash string) (User, error) {
	var user User
	err := r.db.QueryRowContext(ctx, r.bind(`SELECT u.id, u.email, u.first_name, u.last_name, u.display_name, u.status, u.created_at FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > CURRENT_TIMESTAMP`), tokenHash).Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.DisplayName, &user.Status, &user.CreatedAt)
	return user, err
}

func (r *Repository) ListUsers(ctx context.Context, limit int) ([]User, error) {
	rows, err := r.db.QueryContext(ctx, r.bind(`SELECT id, email, first_name, last_name, display_name, status, created_at FROM users WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT ?`), limit)
	if err != nil { return nil, err }
	defer rows.Close()
	var users []User
	for rows.Next() {
		var user User
		if err := rows.Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.DisplayName, &user.Status, &user.CreatedAt); err != nil { return nil, err }
		users = append(users, user)
	}
	return users, rows.Err()
}

func (r *Repository) CheckPassword(user User, password string) bool {
	var hash string
	err := r.db.QueryRowContext(context.Background(), r.bind(`SELECT password_hash FROM users WHERE id = ?`), user.ID).Scan(&hash)
	return err == nil && bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}

func (r *Repository) CreateSession(ctx context.Context, userID, tokenHash string, expires time.Time, agent, ip string) error {
	_, err := r.db.ExecContext(ctx, r.bind(`INSERT INTO sessions (id, user_id, token_hash, user_agent, ip_address, expires_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)`), newID(), userID, tokenHash, agent, ip, expires, time.Now().UTC())
	return err
}

func (r *Repository) RevokeSession(ctx context.Context, tokenHash string) error {
	_, err := r.db.ExecContext(ctx, r.bind(`UPDATE sessions SET revoked_at = CURRENT_TIMESTAMP WHERE token_hash = ?`), tokenHash)
	return err
}
