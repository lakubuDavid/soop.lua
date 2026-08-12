# CLI and API Testing Tools

## usql

`usql` is the preferred interactive SQL client for local CLI work. It supports PostgreSQL, SQLite, and MySQL-style connections through one command-line interface.

Use it for:

- Inspecting local development data
- Running focused diagnostic queries
- Checking migrations
- Comparing database behavior between backends

The project should expose database tasks that print the selected connection and invoke `usql` through `mise`.

## Hurl

Hurl is the preferred checked-in HTTP scenario tool. Store repeatable API workflows in `tests/http/`:

- Authentication flows
- CRUD workflows
- Permission failures
- Validation errors
- HTMX response headers
- Redirect behavior

Hurl tests should be deterministic and use fixture data or an isolated test database.

## xh

`xh` is preferred for quick exploratory API requests during development because it is concise and readable:

```sh
xh GET :8080/healthz
xh POST :8080/api/login email=user@example.com password=secret
```

Exploration commands belong in developer documentation or scripts, not as a replacement for checked-in Hurl scenarios.

## Playwright

Playwright is the end-to-end browser test runner. Use it for flows that cross the browser, Go server, HTMX, Alpine.js, TypeScript, and API boundary:

- Login
- Navigation and partial swaps
- Forms and dialogs
- Responsive navigation
- Permission-aware navigation
- Critical domain workflows

Prefer stable roles, labels, and `data-testid` attributes over CSS implementation selectors.
