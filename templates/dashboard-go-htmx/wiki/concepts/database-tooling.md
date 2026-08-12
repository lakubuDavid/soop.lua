# Database Tooling

## Supported backends

The template supports:

- PostgreSQL as the primary production-oriented backend
- SQLite/libSQL for embedded deployments and Turso later
- MySQL for compatible hosted deployments

The logical schema is shared, but migrations and SQLC queries are dialect-specific where SQL syntax or type behavior differs.

## dbmate

Dbmate manages versioned migrations. Each backend has its own migration directory:

```text
db/postgres/migrations/
db/sqlite/migrations/
db/mysql/migrations/
```

The selected backend is configured through environment variables and mise tasks. Never apply migrations from the wrong backend directory.

## sqlc

Each backend has a dedicated SQLC configuration and generated package. Application services depend on repository interfaces owned by the application, not directly on generated SQLC details.

## usql

Use `usql` for manual inspection and diagnostics. Database tasks should select the correct URL and driver before starting the client.

## Portability rules

- Generate IDs in Go rather than relying on vendor UUID functions.
- Avoid database-native enums in shared logical models.
- Keep JSON, timestamps, booleans, and pagination behavior normalized by repositories.
- Test the same repository contract against every supported backend.
- Document backend-specific behavior instead of hiding it in fragile SQL tricks.
