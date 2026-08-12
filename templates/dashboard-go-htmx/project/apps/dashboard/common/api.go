package common

import (
	"context"
	"net/http"

	sharedapi "@@MODULE@@/packages/shared/api_client"
	sharedtypes "@@MODULE@@/packages/shared/types"
)

type APIClient struct { *sharedapi.Client }

type APIError = sharedtypes.APIError

type User = sharedtypes.User

func NewAPIClient(baseURL string, r *http.Request) *APIClient {
	client := sharedapi.New(baseURL)
	if cookie, err := r.Cookie("app_session"); err == nil { client.Token = cookie.Value }
	return &APIClient{Client: client}
}

func (c *APIClient) CurrentUser(ctx context.Context) (User, error) {
	var user User
	err := c.Do(ctx, http.MethodGet, "/api/auth/me", nil, &user)
	return user, err
}

func (c *APIClient) Users(ctx context.Context) ([]User, error) {
	var users []User
	err := c.Do(ctx, http.MethodGet, "/api/users", nil, &users)
	return users, err
}
