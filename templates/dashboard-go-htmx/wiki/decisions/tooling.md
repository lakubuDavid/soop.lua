# Monorepo and External Tooling

**Status**: Accepted

## Context

The dashboard combines Go, templ, UnoCSS, TypeScript, database migrations, SQL generation, API scenarios, and browser tests.

## Decision

Use `mise` as the source of truth for tool versions, environment loading, and monorepo tasks. Prefer:

- `usql` for interactive SQL work
- `Hurl` for checked-in HTTP tests
- `xh` for quick API exploration
- Playwright for browser-level end-to-end tests

## Consequences

- New contributors can bootstrap from one tool configuration.
- Tasks can be run consistently in CI and locally.
- API and browser tests have clear, separate responsibilities.
- The project carries configuration for more tools than a Go-only application.
