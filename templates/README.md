# Adopted Crystal Soop recipes

These templates were adopted from the existing Crystal-based Soop installation
at `~/.config/soop/`.

| Template | Summary |
|---|---|
| `go` | Basic Go console app |
| `go-air` | Go app with air reload |
| `go-backend` | Go chi/sqlc SQLite backend |
| `crystal` | Simple Crystal application |
| `java-console` | Java console application |
| `python` | Simple Python program |
| `csharp-console` | C# console application |
| `hono-bun-drizzle` | Hono Bun Drizzle starter |
| `echo` | Echo project name |

Each recipe is exposed through a Lua `manifest.lua` and uses the current
Soop context, dry-run behavior, logging, and rollback lifecycle. Source files
were copied without caches or `.DS_Store` artifacts.
