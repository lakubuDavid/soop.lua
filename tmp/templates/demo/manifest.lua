-- Example template project.
---@type Manifest
local M = {
  summary = "Small example",
  description = "A small example project template for testing variables, rendering, commands, and dry-run behavior.",
  variables = {
    {
      name = "PROJECT_NAME",
      prompt = "Project directory?",
      default = "demo-project",
      validate = function(value) return #value > 0 end
    },
    {
      name = "AUTHOR",
      prompt = "Author?",
      default = "soop"
    }
  },

  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:copy_template(ctx.template_dir .. "/README.md.tpl", dest .. "/README.md")
    ctx:copy_template(ctx.template_dir .. "/src/main.lua.tpl", dest .. "/src/main.lua")
    ctx:exec({ "printf", "Project created: " .. dest })
  end
}

return M
