local M = {
  summary = "Java console application",
  description = "Creates a Java console application from Maven's quickstart archetype and adds a starter justfile.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "java-console", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    if not ctx:setup_mise(dest, "maven") then error("mise setup failed") end
    if not ctx:exec({ "mvn", "archetype:generate", "-DgroupId=com." .. dest .. ".app", "-DartifactId=" .. dest, "-DarchetypeArtifactId=maven-archetype-quickstart", "-DarchetypeVersion=1.5", "-DinteractiveMode=false" }) then error("Maven setup failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
