package middlewares

import "net/http"

// Authorize is intentionally generic. Domain modules can replace it with
// role/permission checks without changing the dashboard shell.
func Authorize(_ string, next http.Handler) http.Handler { return next }
