local M = {
  summary = "Simple Crystal application",
  description = "Initializes a Crystal application and includes a small starter justfile for common development commands.",
  tooling = { "crystal" },
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "crystal-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    if not ctx:exec({ "crystal", "init", "app", "." }) then error("Crystal init failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
