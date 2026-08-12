package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
	"@@MODULE@@/apps/api/internal/config"
	"@@MODULE@@/apps/api/internal/db"
	"@@MODULE@@/apps/api/internal/handlers"
	"@@MODULE@@/apps/api/internal/middleware"
	"@@MODULE@@/apps/api/internal/repository"
)

func main() {
	_ = godotenv.Load("../../.env", ".env")

	cfg, err := config.Load()
	if err != nil {
		slog.Error("invalid configuration", "error", err)
		os.Exit(1)
	}

	database, err := db.Open(cfg.Database.Driver, cfg.Database.URL)
	if err != nil {
		slog.Error("database connection failed", "error", err)
		os.Exit(1)
	}
	defer database.Close()

	repo := repository.New(database, cfg.Database.Driver)
	auth := middleware.NewAuth(repo, cfg.Auth.Secret, cfg.Auth.SessionTTL)

	r := chi.NewRouter()
	r.Get("/healthz", handlers.Health(database))
	r.Get("/readyz", handlers.Ready(database))
	r.Route("/api", func(r chi.Router) {
		r.Post("/auth/signup", handlers.Signup(repo, auth))
		r.Post("/auth/login", handlers.Login(repo, auth))
		r.Post("/auth/logout", auth.Logout)
		r.Group(func(r chi.Router) {
			r.Use(auth.Require)
			r.Get("/auth/me", handlers.Me)
			r.Get("/users", handlers.Users(repo))
	})
	})

	server := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           r,
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		slog.Info("api listening", "addr", server.Addr, "database", cfg.Database.Driver)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("api stopped", "error", err)
			os.Exit(1)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = server.Shutdown(ctx)
}
