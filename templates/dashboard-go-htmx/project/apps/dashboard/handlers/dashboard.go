package handlers

import (
	"net/http"
	"@@MODULE@@/apps/dashboard/common"
	"@@MODULE@@/apps/dashboard/views"
	dashboardviews "@@MODULE@@/apps/dashboard/views/dashboard"
)

func RedirectDashboard(w http.ResponseWriter, r *http.Request) { http.Redirect(w, r, "/dashboard/overview", http.StatusSeeOther) }

func Overview(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := currentUser(r, cfg)
		_ = dashboardviews.OverviewPage(dashboardviews.OverviewProps{User: &user}).Render(r.Context(), w)
	}
}

func Users(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := currentUser(r, cfg)
		_ = dashboardviews.UsersPage(dashboardviews.UsersProps{User: &user}).Render(r.Context(), w)
	}
}

func Settings(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := currentUser(r, cfg)
		_ = dashboardviews.SettingsPage(dashboardviews.SettingsProps{User: &user}).Render(r.Context(), w)
	}
}

func currentUser(r *http.Request, cfg common.Config) common.User {
	user, err := common.NewAPIClient(cfg.APIURL, r).CurrentUser(r.Context())
	if err != nil { return common.User{} }
	return user
}

var _ = views.Layout
