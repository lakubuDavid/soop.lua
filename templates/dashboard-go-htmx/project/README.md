# @@PROJECT_NAME@@

A domain-neutral Go + HTMX dashboard monorepo.

| | |
|---|---|
| Project type | @@PROJECT_TYPE@@ |
| Primary database | @@DATABASE@@ |
| Module prefix | @@ORG@@ |
| Author | @@AUTHOR@@ |

## Stack

- Go + chi (routing), templ (SSR), HTMX (partial navigation), Alpine.js
  (local interactions), TypeScript (browser modules), UnoCSS (utility CSS)
- dbmate (migrations) + sqlc (typed queries) supporting PostgreSQL, SQLite/
  libSQL (Turso-ready), and MySQL
- mise (tools + monorepo tasks), usql (SQL CLI), Hurl (API tests), xh (API
  exploration), Playwright (browser tests)

## Requirements

- [mise](https://mise.jdx.dev/)

## Setup

```sh
cp .env.example .env   # edit values, especially AUTH_SECRET
mise install           # install pinned tools
mise run setup         # go mod tidy + npm install per app
mise run generate      # templ, sqlc, TypeScript, UnoCSS
mise run db:up         # apply migrations for DB_DRIVER
mise run dev           # api + dashboard with hot reload
```

## Commands

| Command | Description |
|---------|-------------|
| `mise run dev` | Start api + dashboard (goreman) |
| `mise run generate` | Regenerate templ/sqlc/TS/CSS |
| `mise run build` | Build both apps |
| `mise run test` | Go + Hurl + Playwright tests |
| `mise run db:up` | Apply migrations for the selected driver |
| `mise run db:status` | Show migration status |
| `mise run api:test` | Run API Go + Hurl tests |
| `mise run e2e` | Run Playwright browser tests |

## Environment

See `.env.example`. `DB_DRIVER` selects the database (`postgres`, `sqlite`,
`mysql`); `DATABASE_URL` selects the connection string.

## Documentation

See `wiki/` for the architecture, design language, component catalog,
database strategy, and tooling decisions.

## Getting started with a domain

The generated dashboard is intentionally generic. Add your domain as a module:

```text
apps/dashboard/views/dashboard/
├── overview.templ   # already present
├── settings.templ   # already present
├── users.templ      # already present
└── <your-domain>.templ
```

Wire routes in `apps/dashboard/main.go`, add API endpoints in `apps/api`,
add SQLC queries in `db/<driver>/queries/`, and regenerate.
