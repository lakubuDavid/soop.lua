local M = {
  summary = "Java console application",
  description = "Adopted from the Crystal Soop Java console recipe using Maven's quickstart archetype.",
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "java-console", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    if not ctx:exec({ "mvn", "archetype:generate", "-DgroupId=com." .. dest .. ".app", "-DartifactId=" .. dest, "-DarchetypeArtifactId=maven-archetype-quickstart", "-DarchetypeVersion=1.5", "-DinteractiveMode=false" }) then error("Maven setup failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
