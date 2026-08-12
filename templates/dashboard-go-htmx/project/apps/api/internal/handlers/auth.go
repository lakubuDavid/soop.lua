package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"@@MODULE@@/apps/api/internal/middleware"
	"@@MODULE@@/apps/api/internal/repository"
)

type authRequest struct {
	Email     string `json:"email"`
	Password  string `json:"password"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}

func Signup(repo *repository.Repository, auth *middleware.Auth) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var input authRequest
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil || input.Email == "" || input.Password == "" {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "email and password are required"})
			return
		}
		user, err := repo.CreateUser(r.Context(), input.Email, input.Password, input.FirstName, input.LastName)
		if err != nil {
			writeJSON(w, http.StatusConflict, map[string]string{"error": "unable to create user"})
			return
		}
		session, err := auth.CreateSession(r.Context(), user.ID, r)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "unable to create session"})
			return
		}
		auth.SetCookie(w, session)
		writeJSON(w, http.StatusCreated, user)
	}
}

func Login(repo *repository.Repository, auth *middleware.Auth) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var input authRequest
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request"})
			return
		}
		user, err := repo.FindUserByEmail(r.Context(), input.Email)
		if err != nil || !repo.CheckPassword(user, input.Password) {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
			return
		}
		session, err := auth.CreateSession(r.Context(), user.ID, r)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "unable to create session"})
			return
		}
		auth.SetCookie(w, session)
		writeJSON(w, http.StatusOK, user)
	}
}

func Me(w http.ResponseWriter, r *http.Request) {
	user, ok := middleware.UserFromContext(r.Context())
	if !ok {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}
	writeJSON(w, http.StatusOK, user)
}

func _unused(_ error) { _ = errors.Is }
