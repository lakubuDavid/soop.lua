-- name: GetAllTasks :many
SELECT
  *
FROM
  tasks;

-- name: AddTask :exec
INSERT INTO tasks(content) VALUES (:content) RETURNING *;
