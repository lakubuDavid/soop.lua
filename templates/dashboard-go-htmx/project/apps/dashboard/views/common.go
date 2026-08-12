package views

import (
	"net/http"
	"@@MODULE@@/apps/dashboard/common"
	"@@MODULE@@/apps/dashboard/middlewares"
)

type PageProps struct { Error string; Success string }
type AuthenticatedProps struct { PageProps; User *common.User }

func NewAuthenticatedProps(r *http.Request) *AuthenticatedProps {
	user := common.User{}
	if value, err := r.Cookie(common.SessionCookie); err == nil { _ = value }
	return &AuthenticatedProps{PageProps: PageProps{Error: r.URL.Query().Get("error"), Success: r.URL.Query().Get("success")}, User: &user}
}

func IsHTMX(r *http.Request) bool { return r.Header.Get("HX-Request") == "true" && r.Header.Get("HX-Boosted") != "true" }

var _ = middlewares.Noop
