# Adopted project recipes

These templates were migrated from an existing YAML-based recipe collection
and adapted to the Lua Soop manifest and context system.

| Template | Summary |
|---|---|
| `go` | Basic Go console app |
| `go-air` | Go app with air reload |
| `go-backend` | Go chi/sqlc SQLite backend |
| `rust` | Rust binary application |
| `crystal` | Simple Crystal application |
| `java-console` | Java console application |
| `python` | Simple Python program |
| `csharp-console` | C# console application |
| `hono-bun-drizzle` | Hono Bun Drizzle starter |
| `echo` | Echo project name |

Each recipe is exposed through a Lua `manifest.lua` and uses the current
Soop context, dry-run behavior, logging, and rollback lifecycle. Source files
were copied without caches or `.DS_Store` artifacts.
