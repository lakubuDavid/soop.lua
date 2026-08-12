local M = {
  summary = "Simple Python program",
  description = "Adopted from the Crystal Soop Python recipe with a hello-world entrypoint and justfile.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "python-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
