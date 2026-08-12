#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/soop-escape.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/templates/escape"
cat > "$TMP/templates/escape/manifest.lua" <<'EOF'
local M = {
  scaffold = function(ctx)
    ctx.vars.VALUE = "rendered"
    ctx:scaffold_dir(ctx.template_dir .. "/project", "output")
  end
}
return M
EOF
mkdir -p "$TMP/templates/escape/project"
cat > "$TMP/templates/escape/project/runtime.txt" <<'EOF'
\${DATABASE}
@@VALUE@@
\@@LITERAL@@
EOF

(cd "$TMP" && SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" new escape >/dev/null)

[ "$(sed -n '1p' "$TMP/output/runtime.txt")" = '${DATABASE}' ]
[ "$(sed -n '2p' "$TMP/output/runtime.txt")" = 'rendered' ]
[ "$(sed -n '3p' "$TMP/output/runtime.txt")" = '@@LITERAL@@' ]
rm -rf "$TMP/output"

printf '%s\n' 'ok - scaffold token escaping preserves runtime interpolation'
