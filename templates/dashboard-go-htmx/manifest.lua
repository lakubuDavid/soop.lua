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

    local function must_exec(command, opts)
      if not ctx:exec(command, opts) then
        error("Command failed: " .. (type(command) == "table" and table.concat(command, " ") or command))
      end
    end

    -- Derived variables available to every rendered file.
    ctx.vars.MODULE = ctx.vars.ORG .. "/" .. ctx.vars.PROJECT_NAME

    ctx:mkdir(dest)
    ctx:scaffold_dir(tpl .. "/project", dest)
    ctx:scaffold_dir(tpl .. "/wiki", dest .. "/wiki")

    must_exec({ "cd", dest, "&&", "git", "init" })
    must_exec({ "cd", dest, "&&", "git", "add", "--", "README.md", ".env.example", ".gitignore", "Procfile.dev", "go.work", "mise.toml", "apps", "packages", "db", "wiki" })
    must_exec({ "cd", dest, "&&", "git", "commit", "-m", "'Initial scaffold'" })

    if ctx.dry_run then
      -- The destination is intentionally not created during dry-run, so ask
      -- mise to inspect the template's tool configuration instead.
      if ctx:exec("command -v mise >/dev/null 2>&1") then
        must_exec({ "mise", "install", "--dry-run", "-C", tpl .. "/project" }, { run_in_dry_run = true })
      else
        print("[dry-run] mise was not found; would run mise install --dry-run")
      end
    else
      local install = ctx:prompt("Install project tools with mise now? y/N", "n")
      if install:lower() == "y" or install:lower() == "yes" then
        if ctx:exec("command -v mise >/dev/null 2>&1") then
          must_exec({ "cd", dest, "&&", "mise", "install" })
        else
          print("mise was not found. Install mise, then run:")
          print("  cd " .. dest .. " && mise install")
        end
      else
        print("Tools were not installed. Install mise, then run:")
        print("  cd " .. dest .. " && mise install")
      end
    end

    print("\nNext steps:")
    print("  cd " .. dest)
    print("  mise run setup && mise run generate")
    print("  mise run db:up")
    print("  mise run dev")
  end
}

return M
