#!/bin/sh
# Install soop from a checkout or directly via: curl -fsSL URL/install.sh | sh
set -eu

REPO_URL=${SOOP_REPO_URL:-https://github.com/lakubuDavid/soop.lua.git}
BIN_DIR=${SOOP_BIN_DIR:-"$HOME/.local/bin"}
TEMPLATE_DIR=${SOOP_TEMPLATE_DIR:-"$HOME/.soop/templates"}
REQUESTED_VERSION=${SOOP_VERSION:-}
FORCE=${SOOP_FORCE:-0}
QUIET=${SOOP_QUIET:-0}
DRY_RUN=0
POSITIONAL_BIN_DIR=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force|--fforce) FORCE=1 ;;
    --quiet|-q) QUIET=1 ;;
    --yes|-y) SOOP_YES=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --version)
      [ "$#" -ge 2 ] || { printf '%s\n' 'error: --version requires a value' >&2; exit 2; }
      REQUESTED_VERSION=$2
      shift
      ;;
    --version=*) REQUESTED_VERSION=${1#--version=} ;;
    --bin-dir)
      [ "$#" -ge 2 ] || { printf '%s\n' 'error: --bin-dir requires a value' >&2; exit 2; }
      BIN_DIR=$2
      shift
      ;;
    --bin-dir=*) BIN_DIR=${1#--bin-dir=} ;;
    --templates-dir)
      [ "$#" -ge 2 ] || { printf '%s\n' 'error: --templates-dir requires a value' >&2; exit 2; }
      TEMPLATE_DIR=$2
      shift
      ;;
    --templates-dir=*) TEMPLATE_DIR=${1#--templates-dir=} ;;
    --help|-h)
      cat <<'EOF'
Usage: install.sh [options] [bin-dir]

Options:
  --force, --fforce       Reinstall without the same-version prompt
  --quiet, -q             Suppress the banner
  --yes, -y               Accept installation and completion prompts
  --dry-run               Show the planned install without cloning or writing
  --version VERSION       Install a tagged release, such as 0.1.3 or v0.1.3
  --bin-dir DIR           Override the launcher directory
  --templates-dir DIR     Override the template directory
  --help, -h              Show this help
EOF
      exit 0
      ;;
    --) shift; break ;;
    -*) printf '%s\n' "error: unknown option: $1" >&2; exit 2 ;;
    *)
      [ -z "$POSITIONAL_BIN_DIR" ] || { printf '%s\n' 'error: only one positional bin directory is allowed' >&2; exit 2; }
      POSITIONAL_BIN_DIR=$1
      ;;
  esac
  shift
done
[ -z "$POSITIONAL_BIN_DIR" ] || BIN_DIR=$POSITIONAL_BIN_DIR

if [ -t 1 ] && [ "$QUIET" != "1" ] && [ -z "${NO_COLOR:-}" ]; then
  CYAN='\033[38;2;116;141;166m'; GREEN='\033[38;2;156;180;204m'; LAVENDER='\033[38;2;211;206;223m'; YELLOW='\033[38;2;242;215;217m'; RESET='\033[0m'
else
  CYAN=; GREEN=; LAVENDER=; YELLOW=; RESET=
fi

log() {
  [ "$QUIET" = "1" ] || printf '%b\n' "$1"
}

confirm() {
  prompt=$1
  default=$2
  if [ "${SOOP_YES:-}" = "1" ] || [ "${SOOP_YES:-}" = "true" ]; then
    return 0
  fi
  if [ ! -r /dev/tty ]; then
    printf '%s\n' 'error: no interactive terminal; use --yes to confirm' >&2
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

if [ "$QUIET" != "1" ]; then
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
fi

if [ "$DRY_RUN" = "1" ]; then
  ref=${REQUESTED_VERSION:-latest}
  log "[dry-run] would install soop release: $ref"
  log "[dry-run] launcher: $BIN_DIR/soop"
  log "[dry-run] templates: $TEMPLATE_DIR"
  exit 0
fi

confirm "${YELLOW}Continue with installation? [Y/n] ${RESET}" y || { printf '%s\n' 'Installation cancelled.'; exit 0; }

SCRIPT_DIR=$(CDPATH=; cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=$SCRIPT_DIR
TEMP_DIR=

# A curl-piped script has no usable checkout beside it. Clone after the initial
# confirmation, and use a requested release tag when one was supplied.
if [ ! -f "$SOURCE_DIR/soop" ] || [ ! -d "$SOURCE_DIR/libs" ] || [ ! -f "$SOURCE_DIR/VERSION" ] || [ -n "$REQUESTED_VERSION" ]; then
  command -v git >/dev/null 2>&1 || { printf '%s\n' 'error: git is required' >&2; exit 1; }
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/soop-install.XXXXXX")
  trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM
  clone_ref=
  if [ -n "$REQUESTED_VERSION" ]; then
    case "$REQUESTED_VERSION" in v*) clone_ref=$REQUESTED_VERSION ;; *) clone_ref="v$REQUESTED_VERSION" ;; esac
  fi
  if [ -n "$clone_ref" ]; then
    log "${CYAN}Cloning soop release $clone_ref...${RESET}"
    git clone --depth 1 --branch "$clone_ref" "$REPO_URL" "$TEMP_DIR/repo"
  else
    log "${CYAN}Cloning latest soop...${RESET}"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"
  fi
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
  printf '%s\n' "error: invalid VERSION: $CURRENT_VERSION" >&2
  exit 1
fi

INSTALLED_VERSION=uninstalled
if [ -f "$BIN_DIR/VERSION" ]; then
  INSTALLED_VERSION=$(cat "$BIN_DIR/VERSION")
  is_version "$INSTALLED_VERSION" || INSTALLED_VERSION=unknown
fi

if [ "$FORCE" != "1" ]; then
  if [ "$INSTALLED_VERSION" = "$CURRENT_VERSION" ]; then
    confirm "${YELLOW}Version $CURRENT_VERSION is already installed. Clean reinstall? [y/N] ${RESET}" n || { printf '%s\n' 'Reinstall cancelled.'; exit 0; }
  elif [ "$INSTALLED_VERSION" = uninstalled ]; then
    confirm "${YELLOW}Install soop version $CURRENT_VERSION? [Y/n] ${RESET}" y || { printf '%s\n' 'Installation cancelled.'; exit 0; }
  else
    confirm "${YELLOW}Upgrade soop from $INSTALLED_VERSION to $CURRENT_VERSION? [Y/n] ${RESET}" y || { printf '%s\n' 'Upgrade cancelled.'; exit 0; }
  fi
fi

if [ "$FORCE" = "1" ]; then
  log "${YELLOW}Force reinstall enabled.${RESET}"
fi

rm -f "$BIN_DIR/soop" "$BIN_DIR/VERSION" "$BIN_DIR/version.lua" "$BIN_DIR/common.lua" "$BIN_DIR/completion.lua"
rm -rf "$BIN_DIR/libs" "$TEMPLATE_DIR"
mkdir -p "$BIN_DIR" "$TEMPLATE_DIR"
cp "$SOURCE_DIR/soop" "$BIN_DIR/soop"
cp "$SOURCE_DIR/VERSION" "$SOURCE_DIR/version.lua" "$SOURCE_DIR/common.lua" "$SOURCE_DIR/completion.lua" "$BIN_DIR/"
cp -R "$SOURCE_DIR/libs" "$BIN_DIR/libs"
cp -R "$SOURCE_DIR/templates/." "$TEMPLATE_DIR/"
chmod 755 "$BIN_DIR/soop"

log "${GREEN}Installed soop $CURRENT_VERSION.${RESET}"
log "${GREEN}Launcher:${RESET} $BIN_DIR/soop"
log "${GREEN}Templates:${RESET} $TEMPLATE_DIR"

install_completion() {
  shell_name=${SHELL##*/}
  case "$shell_name" in
    bash)
      completion_dir=${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions
      completion_file=$completion_dir/soop
      ;;
    zsh)
      completion_dir=${SOOP_ZSH_COMPLETION_DIR:-$HOME/.zfunc}
      completion_file=$completion_dir/_soop
      ;;
    fish)
      completion_dir=${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions
      completion_file=$completion_dir/soop.fish
      ;;
    *)
      log "${YELLOW}Could not detect Bash, Zsh, or Fish; skipping completion.${RESET}"
      return 0
      ;;
  esac
  mkdir -p "$completion_dir"
  "$BIN_DIR/soop" completion "$shell_name" > "$completion_file"
  log "${GREEN}Installed $shell_name completion:${RESET} $completion_file"
}

detected_shell=${SHELL##*/}
case "$detected_shell" in
  bash|zsh|fish)
    if [ "${SOOP_YES:-}" = "1" ] || [ "${SOOP_YES:-}" = "true" ]; then
      install_completion
    elif [ -r /dev/tty ] && confirm "${YELLOW}Install $detected_shell shell completion? [Y/n] ${RESET}" y; then
      install_completion
    else
      log "${LAVENDER}Shell completion not installed.${RESET}"
    fi
    ;;
  *) log "${LAVENDER}Shell completion not installed (unsupported shell: ${detected_shell:-unknown}).${RESET}" ;;
esac

log "${YELLOW}Add to PATH if needed:${RESET}"
log "  export PATH=\"$BIN_DIR:\$PATH\""
