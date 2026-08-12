# dashboard-go-htmx template

Domain-neutral Go + HTMX dashboard scaffold for soop.

Generates a monorepo with an API service, an SSR dashboard, shared packages,
per-dialect database setup, and a documentation wiki. Designed for SaaS
products, internal tools, blogs/CMS, tourism guides, marketplaces, and
platforms. The hotel reservation application is the reference implementation
for interaction patterns but is not the template's domain.

## Usage

```sh
SOOP_TEMPLATES_DIR="$(pwd)/templates" ./soop new dashboard-go-htmx
SOOP_TEMPLATES_DIR="$(pwd)/templates" ./soop --dry-run new dashboard-go-htmx
```

## Template variables

| Variable       | Prompt                      | Default          |
|----------------|-----------------------------|------------------|
| `PROJECT_NAME` | Project name                | `my-dashboard`   |
| `PROJECT_TYPE` | Project type preset         | `internal-tool`  |
| `ORG`          | Module prefix               | `example.com`    |
| `AUTHOR`       | Author                      | `Anonymous`      |
| `DATABASE`     | Primary database            | `postgres`       |

Derived:

- `MODULE` = `ORG/PROJECT_NAME` (Go module prefix)

## Rendered tokens

Files in `project/` are rendered with `@@NAME@@` (substituted, empty when
unknown) and `${NAME}` (substituted, literal when unknown). Prefix either token
with a backslash to preserve it for the generated project, for example
`\${DATABASE}` or `\@@NAME@@`. This keeps Go, TypeScript, CSS, and shell
runtime interpolation safe.

## Toolchain bootstrapping

The template source `project/mise.toml` includes a `[tools]` block using major
versions only. During scaffolding, the manifest asks whether tools should be
installed immediately. If accepted and `mise` is available, it runs:

```sh
mise install
```

If declined, or if `mise` is unavailable, the generated instructions show how
to install it later. This keeps the template easy to inspect while avoiding
unnecessary installation during every scaffold.

## Generated project

```text
<project>/
├── apps/
│   ├── api/          chi REST API, auth, db + sqlc setup
│   └── dashboard/    templ + htmx + Alpine + UnoCSS + TS
├── packages/shared/  shared Go types and API client
├── db/               per-dialect dbmate migrations + sqlc
├── modules/          optional child manifests (auth is included)
├── wiki/             design docs copied from the template
├── go.work
├── mise.toml         monorepo tasks + external tools
└── Procfile.dev
```

## Documentation

See [wiki/](wiki/) — the design contract for this template.
