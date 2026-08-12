local M = {
  summary = "Simple Crystal application",
  description = "Adopted from the Crystal Soop crystal recipe: initializes a Crystal app and includes a starter justfile.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "crystal-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    if not ctx:exec({ "crystal", "init", "app", dest }) then error("Crystal init failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
