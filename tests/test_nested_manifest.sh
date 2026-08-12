#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/soop-nested.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/templates/parent/child"
cat > "$TMP/templates/parent/manifest.lua" <<'EOF'
local M = {
  variables = {
    { name = "PARENT_VALUE", prompt = "Parent value?", default = "parent" }
  },
  scaffold = function(ctx)
    ctx:run_child("child/manifest.lua")
  end
}
return M
EOF
cat > "$TMP/templates/parent/child/manifest.lua" <<'EOF'
local M = {
  variables = {
    { name = "PARENT_VALUE", inherit = true },
    { name = "LOCAL_VALUE", prompt = "Child value?", default = "child" }
  },
  scaffold = function(ctx)
    assert(ctx.is_child == true)
    assert(ctx.depth == 1)
    assert(ctx.parent.vars.PARENT_VALUE == "from-parent")
    assert(ctx.vars.PARENT_VALUE == "from-parent")
    assert(ctx.vars.LOCAL_VALUE == "from-child")
    ctx:copy_template(ctx.template_dir .. "/result.txt.tpl", "result.txt")
  end
}
return M
EOF
cat > "$TMP/templates/parent/child/result.txt.tpl" <<'EOF'
${PARENT_VALUE}/${LOCAL_VALUE}
EOF

(cd "$TMP" && printf '%s\n' 'from-parent' 'from-child' | SOOP_TEMPLATES_DIR="$TMP/templates" "$SOOP" new parent >/dev/null)
[ "$(cat "$TMP/result.txt")" = 'from-parent/from-child' ]

printf '%s\n' 'ok - child manifest inherits explicitly and prompts for local variables'
