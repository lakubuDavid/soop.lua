-- Auth module child manifest.
-- Shared project values are explicit inheritances; module configuration is local.
---@type Manifest
local M = {
  variables = {
    { name = "PROJECT_NAME", inherit = true },
    { name = "ORG", inherit = true },
    { name = "DATABASE", inherit = true },
    {
      name = "AUTH_SESSION_TTL",
      prompt = "Session lifetime in hours?",
      default = "24",
      validate = function(value) return tonumber(value) ~= nil and tonumber(value) > 0 end
    }
  },

  scaffold = function(ctx)
    assert(ctx.is_child == true)
    assert(ctx.depth == 1)
    ctx:scaffold_dir(ctx.template_dir .. "/project", ctx.destination .. "/modules/auth")
    ctx:info("auth module added")
  end,

  cleanup = function(ctx)
    ctx:exec("rm -rf " .. ctx.destination .. "/modules/auth")
  end
}

return M
