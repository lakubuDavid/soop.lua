local M = {
  summary = "Go app with air reload",
  description = "Initializes a Go module and configures air for fast local hot-reload development.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "go-air-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    if not ctx:setup_mise(dest, "go") then error("mise setup failed") end
    if not ctx:exec({ "cd", dest, "&&", "go", "mod", "init", dest, "&&", "air", "init" }) then error("Go air setup failed") end
  end
}
return M
