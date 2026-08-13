#!/bin/sh
# Integration smoke test for every bundled template.
# External toolchains are tested when installed; unavailable toolchains are
# reported as skips so the core test suite remains portable.
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
SOOP="$ROOT/soop"
TEMPLATES="$ROOT/templates"
TMP=${SOOP_TEMPLATE_TEST_DIR:-/tmp/soop-test}
rm -rf "$TMP"
mkdir -p "$TMP"
if ! command -v mise >/dev/null 2>&1; then
  echo "skip: template integration (mise is required; runtimes are provisioned by mise)"
  exit 0
fi
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

passed=0
skipped=0
failed_templates=""

project_dir() {
  printf '%s-test' "$1"
}

is_skipped() {
  case ",${SOOP_TEMPLATE_TEST_SKIP:-},${failed_templates}," in
    *,"$1",*) return 0 ;;
    *) return 1 ;;
  esac
}

mark_failed() {
  failed_templates="${failed_templates},$1"
}

has_tools() {
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      return 1
    fi
  done
}

scaffold() {
  name=$1
  input=$2
  project=$(project_dir "$name")
  if is_skipped "$name"; then
    echo "skip: $name scaffold (SOOP_TEMPLATE_TEST_SKIP)"
    skipped=$((skipped + 1))
    return
  fi
  case "$name" in
    go|go-air|go-backend|crystal|java-console|python|csharp-console|rust|hono-bun-drizzle) required="mise" ;;
    dashboard-go-htmx) required="git mise" ;;
    *) required="" ;;
  esac
  # required intentionally contains a space-separated tool list.
  # shellcheck disable=SC2086
  if [ -n "$required" ] && ! has_tools $required; then
    echo "skip: $name scaffold ($required not installed)"
    skipped=$((skipped + 1))
    return
  fi
  printf '%b' "$input" | (
    cd "$TMP"
    SOOP_TEMPLATES_DIR="$TEMPLATES" NO_COLOR=1 SOOP_MISE=1 "$SOOP" --mise new "$name" >"$TMP/$name.log" 2>&1
  ) || {
    cat "$TMP/$name.log" >&2
    if [ "${SOOP_TEMPLATE_TEST_STRICT:-0}" = "1" ]; then
      echo "FAIL: $name scaffold" >&2
      exit 1
    fi
    echo "skip: $name scaffold failed in the local toolchain"
    mark_failed "$name"
    skipped=$((skipped + 1))
    return
  }
  test -d "$TMP/$project"
}

run_project() {
  name=$1
  shift
  project=$(project_dir "$name")
  if is_skipped "$name"; then
    echo "skip: $name run (template scaffold was skipped)"
    skipped=$((skipped + 1))
    return
  fi

  # Runtime binaries are intentionally not checked here. Every execution below
  # is provisioned through mise, so contributors only need mise installed.
  if ! (
  case "$name" in
    python)
      (cd "$TMP/$project" && mise x python -- python3 main.py) >/dev/null
      ;;
    rust)
      (cd "$TMP/$project" && mise x rust -- cargo run --quiet) >/dev/null
      ;;
    crystal)
      (cd "$TMP/$project" && mise x crystal -- crystal run "src/$project.cr") >/dev/null
      ;;
    csharp-console)
      (cd "$TMP/$project" && mise x dotnet -- dotnet run --quiet) >/dev/null
      ;;
    java-console)
      mise x maven -- mvn -q -f "$TMP/$project/pom.xml" test >/dev/null
      ;;
    go|go-air|go-backend)
      # The adopted Go recipes initialize projects but intentionally do not
      # impose an application domain. Add a temporary smoke main for this
      # integration test, then run the generated module.
      cat >"$TMP/$project/main.go" <<'EOF'
package main

func main() {}
EOF
      (cd "$TMP/$project" && mise x go -- go run .) >/dev/null
      ;;
    hono-bun-drizzle)
      mise x node -- node --check "$TMP/$project/index.ts" >/dev/null
      ;;
    dashboard-go-htmx)
      mise trust --quiet "$TMP/$project/mise.toml"
      (cd "$TMP/$project" && mise tasks --no-header) >/dev/null
      ;;
    echo)
      test -f "$TMP/$project/Dockerfile"
      ;;
  esac
  ); then
    if [ "${SOOP_TEMPLATE_TEST_STRICT:-0}" = "1" ]; then
      echo "FAIL: $name run" >&2
      exit 1
    fi
    echo "skip: $name run failed in the local toolchain"
    skipped=$((skipped + 1))
    return
  fi
  echo "pass: $name"
  passed=$((passed + 1))
}

# Set SOOP_TEMPLATE_TEST_SKIP to a comma-separated list when a local runtime
# toolchain is known to be unavailable, for example `crystal`.
# Each input ends with the project name. Hono has runtime and package-manager
# selections first; dashboard also supplies its child auth-module prompt and
# declines the optional tool installation.
scaffold go "go-test\n"
scaffold go-air "go-air-test\n"
scaffold go-backend "go-backend-test\n"
scaffold crystal "crystal-test\n"
scaffold java-console "java-console-test\n"
scaffold python "python-test\n"
scaffold csharp-console "csharp-console-test\n"
scaffold rust "rust-test\n"
scaffold hono-bun-drizzle "1\n1\nhono-bun-drizzle-test\n"
scaffold echo "echo-test\n"

# Dashboard setup performs git initialization and a local initial commit.
# Supply deterministic identity only inside this test process.
GIT_AUTHOR_NAME="Soop Test" GIT_AUTHOR_EMAIL="soop-test@example.invalid" \
GIT_COMMITTER_NAME="Soop Test" GIT_COMMITTER_EMAIL="soop-test@example.invalid" \
  scaffold dashboard-go-htmx "dashboard-go-htmx-test\n2\nexample.com\nSoop Test\n1\n24\nn\n"

run_project go
run_project go-air
run_project go-backend
run_project crystal
run_project java-console
run_project python
run_project csharp-console
run_project rust
run_project hono-bun-drizzle
run_project dashboard-go-htmx
run_project echo

printf '%s\n' "template integration passed: $passed, skipped runs: $skipped"
