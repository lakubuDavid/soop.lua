#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
OUTPUT_DIR="$ROOT/tmp/test-output"

rm -rf "$OUTPUT_DIR"
printf '%s\n' "$OUTPUT_DIR" "Test Author" |
  SOOP_TEMPLATES_DIR="$ROOT/tmp/templates" "$SOOP" new demo >/dev/null

test -f "$OUTPUT_DIR/README.md"
test -f "$OUTPUT_DIR/src/main.lua"
grep -F '# ' "$OUTPUT_DIR/README.md" >/dev/null
grep -F 'Test Author' "$OUTPUT_DIR/README.md" >/dev/null
rm -rf "$OUTPUT_DIR"

printf '%s\n' 'ok - scaffold writes and renders the template'
