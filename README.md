# soop.lua

A small Lua project scaffolder driven by templates written in Lua.

A template is a directory containing a `manifest.lua`. The manifest declares
interactive variables and a `scaffold(ctx)` function that creates the project.
Because the scaffold is Lua, templates can copy files, render variables, and
run project generators without requiring a separate template language.

## Install

`soop` only needs Lua 5.4 and its bundled `argparse` dependency. Install the
launcher into a user-local bin directory:

```sh
./install.sh
# or choose a destination
./install.sh "$HOME/bin"
DEST="$HOME/bin" ./install.sh
```

Make sure the destination is on your `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

The launcher resolves its bundled libraries relative to itself, so it can be
run from any working directory.

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
soop list                   List templates
soop ls                     Alias for list
soop --help                 Show help
```

## Testing

The tests are POSIX shell scripts and cover both dry-run behavior and actual
template rendering:

```sh
./tests/run.sh
```
