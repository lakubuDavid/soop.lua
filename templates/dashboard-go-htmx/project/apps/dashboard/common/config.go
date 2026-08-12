package common

import (
	"fmt"
	"os"
)

type Config struct {
	Port      string
	APIURL    string
	AuthSecret string
}

func LoadConfig() (Config, error) {
	cfg := Config{
		Port: os.Getenv("DASHBOARD_PORT"),
		APIURL: os.Getenv("API_URL"),
		AuthSecret: os.Getenv("AUTH_SECRET"),
	}
	if cfg.Port == "" { cfg.Port = "8081" }
	if cfg.APIURL == "" { cfg.APIURL = "http://localhost:8080" }
	if cfg.AuthSecret == "" { return cfg, fmt.Errorf("AUTH_SECRET is required") }
	return cfg, nil
}
