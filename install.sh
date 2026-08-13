#!/bin/sh
# Install soop from a checkout or directly via: curl -fsSL URL/install.sh | sh
set -eu

REPO_URL=${SOOP_REPO_URL:-https://github.com/lakubuDavid/soop.lua.git}
BIN_DIR=${SOOP_BIN_DIR:-${1:-"$HOME/.local/bin"}}
TEMPLATE_DIR=${SOOP_TEMPLATE_DIR:-"$HOME/.soop/templates"}

SCRIPT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=$SCRIPT_DIR
TEMP_DIR=

# A curl-piped script has no usable checkout beside it. Clone a temporary copy
# so the launcher, bundled libraries, and templates are installed consistently.
if [ ! -f "$SOURCE_DIR/soop" ] || [ ! -d "$SOURCE_DIR/libs" ] || [ ! -d "$SOURCE_DIR/templates" ]; then
  command -v git >/dev/null 2>&1 || {
    printf '%s\n' 'error: git is required when installing from a remote script' >&2
    exit 1
  }
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/soop-install.XXXXXX")
  trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"
  SOURCE_DIR=$TEMP_DIR/repo
fi

[ -f "$SOURCE_DIR/soop" ] || { printf '%s\n' 'error: soop launcher not found' >&2; exit 1; }
[ -d "$SOURCE_DIR/libs" ] || { printf '%s\n' 'error: bundled libs directory not found' >&2; exit 1; }
[ -d "$SOURCE_DIR/templates" ] || { printf '%s\n' 'error: templates directory not found' >&2; exit 1; }

mkdir -p "$BIN_DIR" "$TEMPLATE_DIR"
cp "$SOURCE_DIR/soop" "$BIN_DIR/soop"
cp -R "$SOURCE_DIR/libs" "$BIN_DIR/libs"
cp -R "$SOURCE_DIR/templates/." "$TEMPLATE_DIR/"
chmod 755 "$BIN_DIR/soop"

printf '%s\n' "installed launcher: $BIN_DIR/soop"
printf '%s\n' "installed templates: $TEMPLATE_DIR"
printf '%s\n' 'Add the launcher directory to PATH if needed:'
printf '%s\n' "  export PATH=\"$BIN_DIR:\$PATH\""
