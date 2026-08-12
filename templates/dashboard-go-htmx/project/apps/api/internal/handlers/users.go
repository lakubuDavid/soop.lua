package handlers

import (
	"net/http"

	"@@MODULE@@/apps/api/internal/middleware"
	"@@MODULE@@/apps/api/internal/repository"
)

func Users(repo *repository.Repository) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if user, ok := middleware.UserFromContext(r.Context()); !ok || user.ID == "" {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
			return
		}
		users, err := repo.ListUsers(r.Context(), 50)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "unable to list users"})
			return
		}
		writeJSON(w, http.StatusOK, users)
	}
}
