#!/bin/sh
# Install the soop launcher into a user-local bin directory.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEST=${1:-${DEST:-"$HOME/.local/bin"}}

mkdir -p "$DEST"
ln -sfn "$ROOT/soop" "$DEST/soop"
printf '%s\n' "installed: $DEST/soop -> $ROOT/soop"
printf '%s\n' 'Make sure the destination is on PATH:'
printf '%s\n' "  export PATH=\"$DEST:\$PATH\""
