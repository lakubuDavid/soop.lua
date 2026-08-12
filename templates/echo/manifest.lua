local M = {
  summary = "Echo project name",
  description = "Creates a small Dockerfile-based project and reports the generated project name."
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "echo-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    ctx:info("echo " .. dest)
  end
}
return M
