# Multi-Database Strategy

**Status**: Accepted

## Context

The generated dashboard may use PostgreSQL, SQLite/libSQL for Turso, or MySQL. Dbmate and SQLC need dialect-aware SQL, while application services should remain portable.

## Decision

Maintain one logical schema and separate migrations, queries, and SQLC configurations per backend:

```text
db/postgres/
db/sqlite/
db/mysql/
```

Repositories expose application-owned interfaces. IDs, timestamps, JSON, booleans, and pagination are normalized at the repository boundary.

The initial database module includes users, sessions, email verification, password reset, login attempts, authentication audit events, roles, permissions, and optional organizations/workspaces.

## Alternatives considered

- **One universal SQL migration**: rejected because portable SQL becomes brittle and fails to express useful backend behavior.
- **PostgreSQL only**: rejected because SQLite/libSQL is useful for embedded deployments and Turso, while MySQL remains a supported target.
- **Dashboard connects directly to every database**: rejected for API-backed deployments; the dashboard should normally call an API while the API owns SQLC.

## Consequences

### Positive

- Backend-specific SQL remains clear and testable.
- The dashboard can support both API-backed and full-stack modes.
- Auth and authorization are available from the first migration.

### Negative

- Schema changes must be maintained in three dialects.
- Repository contract tests are required for each backend.
- Turso/libSQL migration execution may require a compatible deployment command beyond local SQLite.
