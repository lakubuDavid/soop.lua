local M = {
  summary = "Go chi/sqlc SQLite backend",
  description = "Adopted from the Crystal Soop go-backend recipe with chi, SQLite, SQLC, db schema/query examples, air, and a justfile.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "go-backend", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    if not ctx:exec({ "cd", dest, "&&", "go", "mod", "init", dest, "&&", "go", "get", "github.com/go-chi/chi/v5", "&&", "go", "get", "github.com/mattn/go-sqlite3", "&&", "air", "init" }) then error("Go backend setup failed") end
  end
}
return M
