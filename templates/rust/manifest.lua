local M = {
  summary = "Rust binary application",
  description = "Creates a Rust binary application with Cargo and includes a small starter justfile.",
  tooling = { "rust" },
  variables = {{ name = "PROJECT_NAME", prompt = "Project directory?", default = "rust-app", validate = function(v) return v:match("^[%w%-_%.]+$") ~= nil end }},
  scaffold = function(ctx)
    local dest = ctx.vars.PROJECT_NAME
    ctx:mkdir(dest)
    if not ctx:exec({ "cargo", "init", "--bin", "." }) then error("cargo init failed") end
    ctx:scaffold_dir(ctx.template_dir .. "/project", dest)
  end
}
return M
