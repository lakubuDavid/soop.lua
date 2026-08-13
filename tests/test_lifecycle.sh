#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/soop-lifecycle.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/templates/rollback"
cat > "$TMP/templates/rollback/manifest.lua" <<'EOF'
local M = {
  scaffold = function(ctx)
    ctx:mkdir("output")
    ctx:exec("touch output/partial")
    ctx:rollback("test rollback")
  end,
  cleanup = function(ctx)
    ctx:exec("rm -rf output")
  end
}
return M
EOF

set +e
(cd "$TMP" && NO_COLOR=1 SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" new rollback >stdout.log 2>stderr.log)
status=$?
set -e

[ "$status" -ne 0 ]
test ! -e "$TMP/output"
grep -F 'test rollback' "$TMP/stderr.log" >/dev/null

echo 'ok - rollback invokes manifest cleanup and reports control flow'
