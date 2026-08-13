#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)

for test in "$ROOT"/tests/test_*.sh; do
  "$test"
done

printf '%s\n' 'all tests passed'
