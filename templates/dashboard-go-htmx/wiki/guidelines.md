# Coding Guidelines

## Scope

This template is a domain-neutral Go dashboard foundation. Do not add hotel-specific vocabulary to shared packages or components. Put product vocabulary in domain modules.

## Code style

- Format Go with `gofmt`.
- Keep generated templ and SQLC files out of manual edits.
- Format TypeScript with the project formatter when configured.
- Keep shell scripts POSIX-compatible unless a Bash feature is required.
- Every embedded shell script begins with `#!/bin/sh` or `#!/bin/bash`.

## Package boundaries

- `cmd/` contains process entrypoints.
- `internal/config` loads and validates configuration.
- `internal/auth` owns authentication contracts.
- `internal/middleware` owns HTTP cross-cutting behavior.
- `internal/api` owns API client behavior.
- `internal/components` and `internal/views` own templ rendering.
- Domain modules own domain handlers, services, types, queries, and views.
- Repository interfaces belong to the application; SQLC implementations belong to database packages.

## HTMX

- Full pages and partials must render from the same typed props where practical.
- Swap only deliberate targets.
- Return `HX-Redirect` or `HX-Trigger` for server-driven navigation and feedback.
- Never assume Alpine state survives a replacement; reinitialize through Alpine lifecycle hooks.

## Database

- Use dbmate for migrations.
- Use SQLC for typed queries.
- Use usql for manual SQL inspection.
- Keep PostgreSQL, SQLite/libSQL, and MySQL migrations separate.
- Never silently run a migration from another backend.
- Generate IDs in Go where cross-database portability matters.

## Testing

- Use Go tests for unit and repository contracts.
- Use Hurl for repeatable HTTP scenarios.
- Use xh for quick API exploration.
- Use Playwright for browser workflows.
- Run tools through mise rather than undocumented global installations.

## Documentation

Document architectural choices in `wiki/decisions/`, tools in `wiki/concepts/`, visual rules in `wiki/docs/`, and user/developer workflows in `wiki/guides/`.
