#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
OUTPUT_DIR="$ROOT/tmp/dry-run-output"

rm -rf "$OUTPUT_DIR"

output=$(printf '%s\n' "$OUTPUT_DIR" "Test Author" |
  SOOP_TEMPLATES_DIR="$ROOT/tmp/templates" "$SOOP" --dry-run new demo 2>&1)

printf '%s\n' "$output" | grep -F '[dry-run] mkdir -p' >/dev/null
printf '%s\n' "$output" | grep -F '[dry-run] render ' | grep -F 'README.md.tpl' >/dev/null
printf '%s\n' "$output" | grep -F '[dry-run] render ' | grep -F 'src/main.lua.tpl' >/dev/null
printf '%s\n' "$output" | grep -F '[dry-run] exec  printf Project created:' >/dev/null

if [ -e "$OUTPUT_DIR" ]; then
  echo "dry-run created $OUTPUT_DIR" >&2
  exit 1
fi

printf '%s\n' 'ok - dry-run performs no filesystem writes and reports actions'
