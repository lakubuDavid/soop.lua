local M = {
  summary = "Hono Bun Drizzle starter",
  description = "Creates a Bun and Hono starter with Drizzle ORM, SQLite examples, reusable components, and a justfile.",
  variables = {
    {
      name = "RUNTIME",
      prompt = "JavaScript runtime?",
      options = { "node", "deno", "bun" },
      default = "node"
    },
    {
      name = "PACKAGE_MANAGER",
      prompt = "Package manager?",
      options = { "npm", "yarn", "bun", "pnpm", "deno" },
      default = "npm"
    },
    {
      name = "PROJECT_NAME",
      prompt = "Project directory?",
      default = "hono-app",
      validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end
    }
  },
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
    local tools = { ctx.vars.RUNTIME }
    if ctx.vars.PACKAGE_MANAGER ~= ctx.vars.RUNTIME then
      tools[#tools + 1] = ctx.vars.PACKAGE_MANAGER
    end
    if not ctx:setup_mise(dest, tools) then error("mise setup failed") end

    local install_commands = {
      npm = "npm install",
      yarn = "yarn install",
      bun = "bun install",
      pnpm = "pnpm install",
      deno = "deno install"
    }
    if not ctx:exec({ "cd", dest, "&&", install_commands[ctx.vars.PACKAGE_MANAGER] }) then
      ctx:warn(install_commands[ctx.vars.PACKAGE_MANAGER] .. " failed; run it later inside " .. dest)
    end
  end
}
return M
