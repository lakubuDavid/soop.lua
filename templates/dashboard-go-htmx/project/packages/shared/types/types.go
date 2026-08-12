package types

import "time"

type User struct {
	ID          string    `json:"id"`
	Email       string    `json:"email"`
	FirstName   string    `json:"first_name"`
	LastName    string    `json:"last_name"`
	DisplayName string    `json:"display_name"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
}

type APIError struct {
	Error   string `json:"error"`
	Message string `json:"message,omitempty"`
}

type Page[T any] struct {
	Items []T `json:"items"`
	Total int   `json:"total"`
	Page  int   `json:"page"`
	Pages int   `json:"pages"`
}
