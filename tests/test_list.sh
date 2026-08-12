#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/soop-list.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/templates/short" "$TMP/templates/long-name"
cat > "$TMP/templates/short/manifest.lua" <<'EOF'
return { description = "Short template" }
EOF
cat > "$TMP/templates/long-name/manifest.lua" <<'EOF'
return { description = "A longer template description" }
EOF

output=$(SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" list)

printf '%s\n' "$output" | grep -F 'NAME' >/dev/null
printf '%s\n' "$output" | grep -F 'Short template' >/dev/null
printf '%s\n' "$output" | grep -F 'A longer template description' >/dev/null

short_line=$(printf '%s\n' "$output" | grep '^short ')
long_line=$(printf '%s\n' "$output" | grep '^long-name ')
[ "$short_line" = "short      Short template" ]
[ "$long_line" = "long-name  A longer template description" ]

echo 'ok - list displays aligned template names and descriptions'
