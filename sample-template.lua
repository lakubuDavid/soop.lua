-- manifest.lua
---@type Manifest
local M = {
  -- Declare what inputs the manifest needs
  variables = {
    {
      name = "PROJECT_NAME",
      prompt = "Project name?",
      default = "my-app",
      validate = function(val) return #val > 0 end
    },
    {
      name = "LANGUAGE",
      prompt = "Programming language?",
      options = { "go", "node", "rust" },
      default = "go"
    },
    {
      name = "AUTHOR",
      prompt = "Author name?",
      default = "Anonymous"
    }
  },

  -- Execution function
  scaffold = function(ctx)
    local vars = ctx.vars -- Collected from user
    local dest = vars.PROJECT_NAME

    ctx:mkdir(dest)
    ctx:copy_template("README.md.tpl", dest .. "/README.md")
    ctx:copy_dir("src/", dest .. "/src/")

    if vars.LANGUAGE == "go" then
      ctx:exec("cd " .. dest .. " && go mod init github.com/" .. vars.PROJECT_NAME)
    elseif vars.LANGUAGE == "node" then
      ctx:copy_template("package.json.tpl", dest .. "/package.json")
      ctx:exec("cd " .. dest .. " && npm install")
    elseif vars.LANGUAGE == "rust" then
      ctx:exec("cd " .. dest .. " && cargo init --name " .. vars.PROJECT_NAME)
    end

    ctx:exec("cd " .. dest .. " && git init && git add . && git commit -m 'Initial'")
  end
}


return M
