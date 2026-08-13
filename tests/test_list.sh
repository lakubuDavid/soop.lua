#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/soop-list.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/templates/short" "$TMP/templates/long-name"
cat > "$TMP/templates/short/manifest.lua" <<'EOF'
return { summary = "Short", description = "Short template details" }
EOF
cat > "$TMP/templates/long-name/manifest.lua" <<'EOF'
return { summary = "Long", description = "A longer template description" }
EOF

output=$(SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" list)

printf '%s\n' "$output" | grep -F 'NAME' >/dev/null
printf '%s\n' "$output" | grep -F 'Short' >/dev/null
printf '%s\n' "$output" | grep -F 'Long' >/dev/null

short_line=$(printf '%s\n' "$output" | grep '^short ')
long_line=$(printf '%s\n' "$output" | grep '^long-name ')
[ "$short_line" = "short      Short" ]
[ "$long_line" = "long-name  Long" ]

details=$(SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" details long-name)
printf '%s\n' "$details" | grep -F 'Summary:     Long' >/dev/null
printf '%s\n' "$details" | grep -F 'Description: A longer template description' >/dev/null

echo 'ok - list displays aligned summaries and details shows descriptions'
