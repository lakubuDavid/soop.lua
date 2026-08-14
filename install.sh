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
  CYAN='\033[38;2;116;141;166m'; GREEN='\033[38;2;156;180;204m'; LAVENDER='\033[38;2;211;206;223m'; YELLOW='\033[38;2;242;215;217m'; RESET='\033[0m'
else
  CYAN=; GREEN=; LAVENDER=; YELLOW=; RESET=
fi

confirm() {
  prompt=$1
  default=$2
  if [ "${SOOP_YES:-}" = "1" ] || [ "${SOOP_YES:-}" = "true" ]; then
    return 0
  fi
  if [ ! -r /dev/tty ]; then
    printf '%s\n' 'error: no interactive terminal; set SOOP_YES=1 to confirm' >&2
    return 1
  fi
  printf '%b' "$prompt" >&2
  read -r answer </dev/tty || answer=
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    n|N|no|NO) return 1 ;;
    '') [ "$default" = "y" ] && return 0 || return 1 ;;
    *) return 1 ;;
  esac
}

printf '%b\n' "${CYAN}      ___           ___           ___           ___${RESET}"
printf '%b\n' "${GREEN}     /  /\\         /  /\\         /  /\\         /  /\\${RESET}"
printf '%b\n' "${LAVENDER}    /  /:/_       /  /::\\       /  /::\\       /  /::\\${RESET}"
printf '%b\n' "${CYAN}   /  /:/ /\\     /  /:/\\:\\     /  /:/\\:\\     /  /:/\\:\\${RESET}"
printf '%b\n' "${GREEN}  /  /:/ /::\\   /  /:/  \\:\\   /  /:/  \\:\\   /  /:/~/:/${RESET}"
printf '%b\n' "${LAVENDER} /__/:/ /:/\\:\\ /__/:/ \\__\\:\\ /__/:/ \\__\\:\\ /__/:/ /:/${RESET}"
printf '%b\n' "${CYAN} \\  \\:\\/:/~/:/ \\  \\:\\ /  /:/ \\  \\:\\ /  /:/ \\  \\:\\/:/${RESET}"
printf '%b\n' "${GREEN}  \\  \\::/ /:/   \\  \\:\\  /:/   \\  \\:\\  /:/   \\  \\::/${RESET}"
printf '%b\n' "${LAVENDER}   \\__\\\\/ /:/     \\  \\:\\/:/     \\  \\:\\/:/     \\  \\:\\${RESET}"
printf '%b\n' "${CYAN}     /__/:/       \\  \\::/       \\  \\::/       \\  \\:\\${RESET}"
printf '%b\n' "${GREEN}     \\__\\/         \\__\\/         \\__\\/         \\__\\/${RESET}"
printf '%b\n' "${GREEN}soop scaffolds projects from Lua manifests, templates, and mise tooling.${RESET}"
printf '%b\n' "${LAVENDER}It supports dry runs, interactive template selection, and shell completion.${RESET}"
printf '%s\n' ''
printf '%s\n' ''
printf '%b\n' "${LAVENDER}Target launcher:${RESET} $BIN_DIR/soop"
printf '%b\n' "${LAVENDER}Target templates:${RESET} $TEMPLATE_DIR"
printf '%s\n' ''
confirm "${YELLOW}Continue with installation? [y/N] ${RESET}" n || { printf '%s\n' 'Installation cancelled.'; exit 0; }

# A curl-piped script has no usable checkout beside it. Clone a temporary copy
# so the launcher, dependencies, and templates can be inspected consistently.
if [ ! -f "$SOURCE_DIR/soop" ] || [ ! -d "$SOURCE_DIR/libs" ] || [ ! -f "$SOURCE_DIR/VERSION" ]; then
  command -v git >/dev/null 2>&1 || { printf '%s\n' 'error: git is required' >&2; exit 1; }
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/soop-install.XXXXXX")
  trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM
  printf '%b\n' "${CYAN}Cloning soop repository...${RESET}"
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"
  SOURCE_DIR=$TEMP_DIR/repo
fi

for required in soop VERSION version.lua common.lua completion.lua; do
  [ -f "$SOURCE_DIR/$required" ] || { printf '%s\n' "error: $required not found" >&2; exit 1; }
done
[ -d "$SOURCE_DIR/libs" ] || { printf '%s\n' 'error: bundled libs directory not found' >&2; exit 1; }
[ -d "$SOURCE_DIR/templates" ] || { printf '%s\n' 'error: templates directory not found' >&2; exit 1; }

is_version() {
  printf '%s\n' "$1" | awk -F. '$0 ~ /^[0-9]+\.[0-9]+\.[0-9]+$/ && NF == 3 { exit 0 } { exit 1 }'
}

CURRENT_VERSION=$(cat "$SOURCE_DIR/VERSION")
if ! is_version "$CURRENT_VERSION"; then
  printf '%s\n' "error: invalid VERSION: $CURRENT_VERSION (expected MAJOR.MINOR.PATCH)" >&2
  exit 1
fi
INSTALLED_VERSION=uninstalled
if [ -f "$BIN_DIR/VERSION" ]; then
  INSTALLED_VERSION=$(cat "$BIN_DIR/VERSION")
  if ! is_version "$INSTALLED_VERSION"; then
    INSTALLED_VERSION=unknown
  fi
fi

if [ "$INSTALLED_VERSION" = "$CURRENT_VERSION" ]; then
  if ! confirm "${YELLOW}Version $CURRENT_VERSION is already installed. Clean reinstall? [y/N] ${RESET}" n; then
    printf '%s\n' 'Reinstall cancelled.'
    exit 0
  fi
elif [ "$INSTALLED_VERSION" = uninstalled ]; then
  if ! confirm "${YELLOW}Install soop version $CURRENT_VERSION? [Y/n] ${RESET}" y; then
    printf '%s\n' 'Installation cancelled.'
    exit 0
  fi
else
  if ! confirm "${YELLOW}Upgrade soop from $INSTALLED_VERSION to $CURRENT_VERSION? [Y/n] ${RESET}" y; then
    printf '%s\n' 'Upgrade cancelled.'
    exit 0
  fi
fi

# Clean only the managed Soop installation before copying the selected version.
rm -f "$BIN_DIR/soop" "$BIN_DIR/VERSION" "$BIN_DIR/version.lua" "$BIN_DIR/common.lua" "$BIN_DIR/completion.lua"
rm -rf "$BIN_DIR/libs" "$TEMPLATE_DIR"
mkdir -p "$BIN_DIR" "$TEMPLATE_DIR"
cp "$SOURCE_DIR/soop" "$BIN_DIR/soop"
cp "$SOURCE_DIR/VERSION" "$SOURCE_DIR/version.lua" "$SOURCE_DIR/common.lua" "$SOURCE_DIR/completion.lua" "$BIN_DIR/"
cp -R "$SOURCE_DIR/libs" "$BIN_DIR/libs"
cp -R "$SOURCE_DIR/templates/." "$TEMPLATE_DIR/"
chmod 755 "$BIN_DIR/soop"

printf '%b\n' "${GREEN}Installed soop $CURRENT_VERSION.${RESET}"
printf '%b\n' "${GREEN}Launcher:${RESET} $BIN_DIR/soop"
printf '%b\n' "${GREEN}Templates:${RESET} $TEMPLATE_DIR"
printf '%b\n' "${YELLOW}Add to PATH if needed:${RESET}"
printf '%s\n' "  export PATH=\"$BIN_DIR:\$PATH\""
