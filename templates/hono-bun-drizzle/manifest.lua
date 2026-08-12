local M = {
  summary = "Hono Bun Drizzle starter",
  description = "Creates a Bun and Hono starter with Drizzle ORM, SQLite examples, reusable components, and a justfile."
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "hono-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    if not ctx:exec({ "cd", dest, "&&", "bun", "install" }) then
      ctx:warn("bun install failed; run it later inside " .. dest)
    end
  end
}
return M
