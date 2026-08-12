package handlers

import (
	"net/http"
	"@@MODULE@@/apps/dashboard/common"
	"@@MODULE@@/apps/dashboard/views/partials"
)

func Stats(_ common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) { _ = partials.Stats(partials.StatsProps{Total: 0, Active: 0, Pending: 0}).Render(r.Context(), w) }
}

func UsersPartial(cfg common.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		users, _ := common.NewAPIClient(cfg.APIURL, r).Users(r.Context())
		_ = partials.UserRows(users).Render(r.Context(), w)
	}
}
