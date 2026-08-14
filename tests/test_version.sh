#!/bin/sh
set -eu

ROOT=$(CDPATH=; cd -- "$(dirname -- "$0")/.." && pwd)
version=$(cat "$ROOT/VERSION")
output=$($ROOT/soop --version)
[ "$output" = "soop $version" ]

printf '%s\n' 'ok - launcher version matches VERSION'
