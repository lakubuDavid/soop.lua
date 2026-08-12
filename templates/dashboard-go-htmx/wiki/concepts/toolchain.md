# Development Toolchain

## What it is

The template uses `mise` as the monorepo tool manager, task runner, environment loader, and external-tool coordinator.

## Why we use it

A dashboard project spans Go, templ, Node, UnoCSS, TypeScript, database tooling, and API/browser testing. `mise` provides one versioned toolchain and a task graph without requiring separate global installations.

## Tools

- Go
- Node and npm
- templ
- UnoCSS CLI
- TypeScript
- air
- dbmate
- sqlc
- usql
- Hurl
- xh
- Playwright
- PostgreSQL, SQLite/libSQL, and MySQL clients as needed

## How we use it

The template source `mise.toml` owns environment loading, monorepo configuration, and tasks, but intentionally does not contain a `[tools]` block. The manifest first checks for `mise`, then runs `mise use TOOL@MAJOR` and `mise install` inside the generated project. This creates the generated project's tool configuration without hardcoding tool versions in the source template. App-level `mise.toml` files may add local tasks but must not silently select incompatible tool versions.

Use task dependencies for generation:

```text
build
├── generate templ
├── generate UnoCSS
├── generate TypeScript
└── compile Go
```

Use `mise run <task>` for project tasks and `mise x -- <tool>` when a tool must run with the managed environment.

## Rules

- Do not require contributors to install project tools globally.
- Pin important tool versions.
- Keep database and API test commands reproducible from a clean checkout.
- Keep long-running process orchestration separate from one-shot generation tasks.
