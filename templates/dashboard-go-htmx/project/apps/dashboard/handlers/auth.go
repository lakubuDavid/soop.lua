package handlers

import (
	"net/http"
	"net/url"
	"@@MODULE@@/apps/dashboard/common"
	"@@MODULE@@/apps/dashboard/views"
)

func LoginPage(w http.ResponseWriter, r *http.Request) { _ = views.Login(views.LoginProps{Error: r.URL.Query().Get("error")}).Render(r.Context(), w) }

func Login(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_ = r.ParseForm()
		client := common.NewAPIClient(cfg.APIURL, r)
		// The shared client supports JSON requests; HTML forms can be adapted in a domain module.
		_ = client
		http.Redirect(w, r, "/dashboard/overview?success="+url.QueryEscape("Login wiring is ready"), http.StatusSeeOther)
	}
}

func Logout(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) { common.ClearSession(w); http.Redirect(w, r, "/login", http.StatusSeeOther) }
}
