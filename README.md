# soop.lua

A small Lua project scaffolder driven by templates written in Lua.

A template is a directory containing a `manifest.lua`. The manifest declares
interactive variables and a `scaffold(ctx)` function that creates the project.
Because the scaffold is Lua, templates can copy files, render variables, and
run project generators without requiring a separate template language.

## Install

`soop` only needs Lua 5.4 and its bundled `argparse` dependency. Install from
a checkout into a user-local bin directory:

```sh
./install.sh
# or choose a destination
./install.sh "$HOME/bin"
SOOP_BIN_DIR="$HOME/bin" ./install.sh
```

The installer also works remotely. It checks for the required launcher,
`libs/`, and `templates/` files; when they are not local it requires `git`,
clones the repository into `/tmp`, and copies the launcher, bundled libraries,
and templates into place:

```sh
curl -fsSL https://raw.githubusercontent.com/lakubuDavid/soop.lua/main/install.sh | sh
```

By default, templates are installed into `~/.soop/templates` and the launcher
into `~/.local/bin`. Override these locations with `SOOP_TEMPLATE_DIR` and
`SOOP_BIN_DIR`.

Make sure the destination is on your `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

The launcher resolves its bundled libraries relative to itself, so it can be
run from any working directory.

## Configuration

Soop loads the first config file it finds from:

```text
$XDG_CONFIG_HOME/soop/config.lua
~/.config/soop/config.lua
~/.soop/config.lua
```

You can also set `SOOP_CONFIG_FILE` to an explicit path. A config is a Lua
table, for example:

```lua
return {
  no_color = false,
  mise = true,
  templates_dir = os.getenv("HOME") .. "/.soop/templates"
}
```

Configuration values can be overridden with environment variables or command
line options. Useful overrides include `SOOP_TEMPLATES_DIR`, `SOOP_MISE=1`,
`NO_COLOR=1`, `--templates-dir <path>`, `--mise`, and `--no-color`.

## Quick start

Templates are loaded from `$SOOP_TEMPLATES_DIR` when it is set. Otherwise,
soop looks in `$PWD/templates`:

```sh
export SOOP_TEMPLATES_DIR="$HOME/.config/soop/templates"
soop new demo
# short alias
soop n demo
```

For a local checkout, the example template can be run from the repository:

```sh
cd tmp
../soop n demo
```

That command uses `tmp/templates/demo` through the default `$PWD/templates`
lookup and creates `tmp/demo-project` by default.

## Dry run

Use `--dry-run` to collect variables and preview the scaffold without writing
files or executing commands:

```sh
SOOP_TEMPLATES_DIR="$(pwd)/tmp/templates" ./soop --dry-run new demo
```

Dry-run output labels each operation with `[dry-run]`.

## Mise tooling

Mise integration is opt-in for templates that support it. Templates declare
their tools in a `tooling` field, for example `tooling = { "go" }`. A tooling
entry can also name a manifest variable; the Hono template uses explicit variable references:
`tooling = { "${RUNTIME}", "${PACKAGE_MANAGER}" }` so the selected tools are used.
Pass `--mise` or set `SOOP_MISE=1` (also accepted: `SOOP_ADD_MISE=1`) to install
the declared latest tools into the generated project:

```sh
soop --mise new go
SOOP_MISE=1 soop new java-console
```

Examples include `go@latest`, `python@latest`, `dotnet@latest`,
`maven@latest`, and `crystal@latest`. The Hono/Bun template additionally
prompts for a JavaScript runtime (`node`, `deno`, or `bun`) and package manager
(`npm`, `yarn`, `bun`, `pnpm`, or `deno`), installing both with mise when they
differ.

## Writing a template

Create a directory under the configured templates directory:

```text
templates/my-app/
├── manifest.lua
└── README.md.tpl
```

Example manifest:

```lua
local M = {
  variables = {
    {
      name = "PROJECT_NAME",
      prompt = "Project directory?",
      default = "my-app"
    }
  },

  scaffold = function(ctx)
    local destination = ctx.vars.PROJECT_NAME
    ctx:mkdir(destination)
    ctx:copy_template(
      ctx.template_dir .. "/README.md.tpl",
      destination .. "/README.md"
    )
  end
}

return M
```

When a whole directory is scaffolded, `ctx:scaffold_dir` renders `@@NAME@@`
tokens and `${NAME}` tokens. Prefix either form with a backslash to preserve
it for the generated project, for example `\${DATABASE}` or `\@@NAME@@`.

`ctx:prompt(message, default)` asks an optional interactive question. In dry
run mode it returns the default without blocking.

Available context methods:

| Method | Purpose |
|---|---|
| `ctx:mkdir(path)` | Create a directory |
| `ctx:copy_file(src, dest)` | Copy a file |
| `ctx:copy_dir(src, dest)` | Copy a directory |
| `ctx:copy_template(src, dest)` | Render `${VARIABLE}` placeholders and write a file |
| `ctx:exec(command)` | Execute a shell command; reported but skipped during dry run |
| `ctx.vars` | Values collected from manifest variables |
| `ctx.template_dir` | Absolute/configured path to the active template |
| `ctx.dry_run` | Whether the current invocation is a dry run |

## Commands

```text
soop new <template-name>    Scaffold a project
soop n <template-name>      Alias for new
soop list                   List template names and short summaries
soop ls                     Alias for list
soop details <template-name> Show summary and full description
soop d <template-name>      Alias for details
soop completion <shell>     Generate bash, zsh, or fish completion
soop --mise                 Enable mise tooling for the generated project
soop --help                 Show help
```

## Shell completion

Generate completion scripts for the shell you use:

```sh
soop completion bash > ~/.local/share/bash-completion/completions/soop
soop completion zsh > ~/.zfunc/_soop
soop completion fish > ~/.config/fish/completions/soop.fish
```

The generated scripts complete commands, options, and current template names.
They query the hidden machine-readable endpoint below, so completions follow
changes to the configured template directory:

```sh
soop __complete templates
```

## Testing

The tests are POSIX shell scripts and cover both dry-run behavior and actual
template rendering:

```sh
./tests/run.sh
```
