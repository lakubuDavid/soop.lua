package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	Port     string
	Database DatabaseConfig
	Auth     AuthConfig
}

type DatabaseConfig struct {
	Driver string
	URL    string
}

type AuthConfig struct {
	Secret     string
	SessionTTL int64
}

func Load() (Config, error) {
	ttl, err := strconv.ParseInt(getenv("SESSION_TTL_HOURS", "24"), 10, 64)
	if err != nil || ttl <= 0 {
		return Config{}, fmt.Errorf("SESSION_TTL_HOURS must be a positive integer")
	}

	cfg := Config{
		Port: getenv("PORT", "8080"),
		Database: DatabaseConfig{
			Driver: getenv("DB_DRIVER", "@@DATABASE@@"),
			URL:    getenv("DATABASE_URL", "postgres://localhost:5432/app?sslmode=disable"),
		},
		Auth: AuthConfig{
			Secret:     os.Getenv("AUTH_SECRET"),
			SessionTTL: ttl,
		},
	}
	if cfg.Auth.Secret == "" {
		return Config{}, fmt.Errorf("AUTH_SECRET is required")
	}
	if cfg.Database.Driver != "postgres" && cfg.Database.Driver != "sqlite" && cfg.Database.Driver != "mysql" {
		return Config{}, fmt.Errorf("unsupported DB_DRIVER: %s", cfg.Database.Driver)
	}
	return cfg, nil
}

func getenv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
