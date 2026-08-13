#!/bin/sh
# Install soop from a checkout or directly via: curl -fsSL URL/install.sh | sh
set -eu

REPO_URL=${SOOP_REPO_URL:-https://github.com/lakubuDavid/soop.lua.git}
BIN_DIR=${SOOP_BIN_DIR:-${1:-"$HOME/.local/bin"}}
TEMPLATE_DIR=${SOOP_TEMPLATE_DIR:-"$HOME/.soop/templates"}
SCRIPT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=$SCRIPT_DIR
TEMP_DIR=

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RESET='\033[0m'
else
  CYAN=; GREEN=; YELLOW=; RESET=
fi

printf '%b\n' "${CYAN}========================================${RESET}"
printf '%b\n' "${CYAN}             soop installer${RESET}"
printf '%b\n' "${CYAN}========================================${RESET}"
printf '%b\n' "${GREEN}soop scaffolds projects from Lua manifests.${RESET}"
printf '%b\n' 'It includes templates, dry-run support, mise tooling, and shell completion.'
printf '%b\n' "Install launcher: $BIN_DIR/soop"
printf '%b\n' "Install templates: $TEMPLATE_DIR"
printf '%b' 'Continue with installation? [y/N] '

if [ "${SOOP_YES:-}" != "1" ] && [ "${SOOP_YES:-}" != "true" ]; then
  if [ -r /dev/tty ]; then
    read -r answer </dev/tty || answer=
    case "$answer" in y|Y|yes|YES) ;; *) printf '%s\n' 'Installation cancelled.'; exit 0 ;; esac
  else
    printf '%s\n' 'error: no interactive terminal; set SOOP_YES=1 to confirm' >&2
    exit 1
  fi
fi

# A curl-piped script has no usable checkout beside it. Clone a temporary copy
# so the launcher, bundled libraries, and templates are installed consistently.
if [ ! -f "$SOURCE_DIR/soop" ] || [ ! -d "$SOURCE_DIR/libs" ] || [ ! -d "$SOURCE_DIR/templates" ]; then
  command -v git >/dev/null 2>&1 || { printf '%s\n' 'error: git is required' >&2; exit 1; }
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/soop-install.XXXXXX")
  trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM
  printf '%b\n' "${CYAN}Cloning soop repository...${RESET}"
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

printf '%b\n' "${GREEN}Installed launcher:${RESET} $BIN_DIR/soop"
printf '%b\n' "${GREEN}Installed templates:${RESET} $TEMPLATE_DIR"
printf '%b\n' "${YELLOW}Add to PATH if needed:${RESET}"
printf '%s\n' "  export PATH=\"$BIN_DIR:\$PATH\""
