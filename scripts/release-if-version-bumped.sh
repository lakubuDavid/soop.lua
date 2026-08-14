#!/bin/sh
# Create a GitHub release when the pushed commit changes VERSION.
set -eu

VERSION_FILE=VERSION
[ -f "$VERSION_FILE" ] || exit 0

if git rev-parse HEAD^ >/dev/null 2>&1 && git diff --quiet HEAD^ HEAD -- "$VERSION_FILE"; then
  exit 0
fi

version=$(cat "$VERSION_FILE")
tag="v$version"

command -v gh >/dev/null 2>&1 || {
  printf '%s\n' "release skipped: gh is not installed" >&2
  exit 0
}
if ! gh auth status >/dev/null 2>&1; then
  printf '%s\n' "release skipped: gh is not authenticated" >&2
  exit 0
fi
if gh release view "$tag" >/dev/null 2>&1; then
  printf '%s\n' "release already exists: $tag"
  exit 0
fi

printf '%s\n' "creating GitHub release: $tag"
gh release create "$tag" --target HEAD --generate-notes --title "$tag"
