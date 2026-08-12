package db

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/go-sql-driver/mysql"
	_ "github.com/jackc/pgx/v5/stdlib"
	_ "modernc.org/sqlite"
)

func Open(driver, url string) (*sql.DB, error) {
	driverName := driver
	if driver == "postgres" {
		driverName = "pgx"
	}
	if driver != "postgres" && driver != "sqlite" && driver != "mysql" {
		return nil, fmt.Errorf("unsupported database driver %q", driver)
	}

	database, err := sql.Open(driverName, url)
	if err != nil {
		return nil, err
	}
	database.SetMaxOpenConns(25)
	database.SetMaxIdleConns(5)
	database.SetConnMaxLifetime(5 * time.Minute)
	if err := database.Ping(); err != nil {
		_ = database.Close()
		return nil, err
	}
	return database, nil
}
