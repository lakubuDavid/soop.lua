-- name: GetUserByEmail :one
SELECT id, email, first_name, last_name, display_name, status, created_at
FROM users WHERE email_normalized = lower(?) AND deleted_at IS NULL;

-- name: ListUsers :many
SELECT id, email, first_name, last_name, display_name, status, created_at
FROM users WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT ?;
