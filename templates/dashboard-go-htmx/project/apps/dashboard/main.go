package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/a-h/templ"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/joho/godotenv"
	"@@MODULE@@/apps/dashboard/common"
	"@@MODULE@@/apps/dashboard/handlers"
	"@@MODULE@@/apps/dashboard/middlewares"
	"@@MODULE@@/apps/dashboard/views"
)

func main() {
	_ = godotenv.Load("../../.env", ".env")
	cfg, err := common.LoadConfig()
	if err != nil { slog.Error("invalid configuration", "error", err); os.Exit(1) }

	r := chi.NewRouter()
	r.Use(middleware.RequestID, middleware.RealIP, middleware.Recoverer, middleware.Timeout(30*time.Second))
	r.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	r.Get("/healthz", handlers.Health)
	r.Get("/login", handlers.LoginPage)
	r.Post("/login", handlers.Login(cfg))
	r.Post("/logout", handlers.Logout(cfg))
	r.Group(func(r chi.Router) {
		r.Use(middlewares.RequireAuth(cfg))
		r.Get("/", handlers.RedirectDashboard)
		r.Get("/dashboard", handlers.RedirectDashboard)
		r.Get("/dashboard/overview", handlers.Overview(cfg))
		r.Get("/dashboard/users", handlers.Users(cfg))
		r.Get("/dashboard/settings", handlers.Settings(cfg))
		r.Get("/partials/stats/overview", handlers.Stats(cfg))
		r.Get("/partials/users", handlers.UsersPartial(cfg))
	})

	server := &http.Server{Addr: ":" + cfg.Port, Handler: r, ReadHeaderTimeout: 10 * time.Second}
	go func() {
		slog.Info("dashboard listening", "addr", server.Addr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed { slog.Error("dashboard stopped", "error", err); os.Exit(1) }
	}()
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = server.Shutdown(ctx)
	_ = templ.NopComponent
}
