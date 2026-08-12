local M = {
  summary = "Basic Go console app",
  description = "Initializes a Go module and includes a small starter justfile for common development commands.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "go-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    if not ctx:exec({ "cd", dest, "&&", "go", "mod", "init", dest }) then error("go mod init failed") end
  end
}
return M
