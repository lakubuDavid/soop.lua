package middlewares

import (
	"net/http"
	"@@MODULE@@/apps/dashboard/common"
)

func RequireAuth(cfg common.Config) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if _, err := r.Cookie(common.SessionCookie); err != nil {
				http.Redirect(w, r, "/login?error=authentication_required", http.StatusSeeOther)
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
