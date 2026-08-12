-- manifest.lua — domain-neutral Go + HTMX dashboard template.
--
-- Scaffolds a monorepo with:
--   apps/api        Go REST API (chi, auth, dbmate/sqlc-ready)
--   apps/dashboard  Go SSR dashboard (templ, htmx, Alpine, UnoCSS, TS)
--   packages/shared Shared Go types and API client
--   db/             Per-dialect dbmate migrations + sqlc configs
--   wiki/           Architecture and design documentation
---
---@type Manifest
local M = {
  variables = {
    {
      name = "PROJECT_NAME",
      prompt = "Project name?",
      default = "my-dashboard",
      validate = function(v) return v:match("^[%w%-_%.]+$") and #v > 0 end
    },
    {
      name = "PROJECT_TYPE",
      prompt = "Project type?",
      options = { "minimal", "admin", "internal-tool", "cms", "saas", "platform" },
      default = "internal-tool"
    },
    {
      name = "ORG",
      prompt = "Module prefix (org/domain)?",
      default = "example.com"
    },
    {
      name = "AUTHOR",
      prompt = "Author?",
      default = "Anonymous"
    },
    {
      name = "DATABASE",
      prompt = "Primary database?",
      options = { "postgres", "sqlite", "mysql" },
      default = "postgres"
    }
  },

  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    local tpl = ctx.template_dir

    local function must_exec(command)
      if not ctx:exec(command) then
        error("Command failed: " .. (type(command) == "table" and table.concat(command, " ") or command))
      end
    end

    -- mise owns the generated project's external toolchain. The template
    -- source mise.toml intentionally contains no [tools] block.
    if not ctx:exec("command -v mise >/dev/null 2>&1") then
      error("mise is required to scaffold dashboard-go-htmx")
    end

    -- Derived variables available to every rendered file.
    ctx.vars.MODULE = ctx.vars.ORG .. "/" .. ctx.vars.PROJECT_NAME

    ctx:mkdir(dest)
    ctx:scaffold_dir(tpl .. "/project", dest)
    ctx:scaffold_dir(tpl .. "/wiki", dest .. "/wiki")

    must_exec({ "cd", dest, "&&", "mise", "use", "--yes",
      "go@1", "node@24", "air@1", "goreman@0", "dbmate@2", "sqlc@1",
      "usql@0", "hurl@6", "xh@0",
      "go:github.com/a-h/templ/cmd/templ@0",
      "npm:unocss@66", "npm:typescript@7" })
    must_exec({ "cd", dest, "&&", "mise", "install" })

    must_exec({ "cd", dest, "&&", "git", "init" })
    must_exec({ "cd", dest, "&&", "git", "add", "--", "README.md", ".env.example", ".gitignore", "Procfile.dev", "go.work", "mise.toml", "apps", "packages", "db", "wiki" })
    must_exec({ "cd", dest, "&&", "git", "commit", "-m", "'Initial scaffold'" })

    print("\nNext steps:")
    print("  cd " .. dest)
    print("  mise install && mise run setup && mise run generate")
    print("  mise run db:up")
    print("  mise run dev")
  end
}

return M
