# Testing Strategy

**Status**: Accepted

## Layers

### Go tests

Test services, repositories, middleware, route behavior, and templ props with `go test ./...`.

### Hurl tests

Use checked-in HTTP scenarios for API contracts, authentication, authorization, redirects, validation, and HTMX headers.

### xh exploration

Use xh for manual development requests. These are exploratory and should become Hurl scenarios when they represent a repeatable requirement.

### Playwright tests

Use Playwright for browser-visible workflows that involve layout, HTMX swaps, Alpine state, TypeScript behavior, and responsive behavior.

## Rules

- Tests must be runnable through mise tasks.
- API tests use an isolated database and deterministic fixtures.
- Browser tests wait on observable UI state, not arbitrary sleeps.
- Critical full-page and HTMX partial routes both receive coverage.
- Each supported database backend runs the repository contract suite where practical.
