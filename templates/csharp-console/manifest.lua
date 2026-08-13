local M = {
  summary = "C# console application",
  description = "Creates a C# console application with dotnet new and adds a starter justfile.",
  tooling = { "dotnet" },
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "csharp-console", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    if not ctx:exec({ "dotnet", "new", "console", "-o", ".", "--use-program-main" }) then error("dotnet setup failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
