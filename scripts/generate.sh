#!/usr/bin/env bash
# Generate the opencode v2 config JSON schema for a release tag.
# Usage: scripts/generate.sh [<tag>]   (default: latest stable v2.* tag)
set -euo pipefail

upstream=https://github.com/anomalyco/opencode
base=https://badgerkin.github.io/opencode-schema/
repo=$(cd "$(dirname "$0")/.." && pwd)

tag=${1:-$(git ls-remote --tags --refs "$upstream" 'v2.*' | awk -F/ '{print $3}' | grep -v -- - | sort -V | tail -1)}
[[ $tag =~ ^v2\.[0-9]+\.[0-9]+$ ]] || { echo "error: '$tag' is not a v2.x.y tag" >&2; exit 1; }
echo "Generating schema for $tag"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

git -c advice.detachedHead=false clone -q --depth 1 -b "$tag" "$upstream" "$work/opencode"
schema_pkg="$work/opencode/packages/schema"
[[ -f $schema_pkg/src/config.ts ]] || { echo "error: $tag has no packages/schema/src/config.ts (layout changed)" >&2; exit 1; }

# Resolve Bun via npx outside the checkout (npm chokes on its workspace "catalog:" deps)
bun=$(cd "$work" && npx -y bun -e 'console.log(process.execPath)')
(cd "$work/opencode" && "$bun" install --ignore-scripts >/dev/null)
mkdir -p "$schema_pkg/script"
cp "$repo/scripts/config-schema.ts" "$schema_pkg/script/"

generate() { # <out dir> <id path>
  mkdir -p "$repo/$1"
  (cd "$schema_pkg" && "$bun" script/config-schema.ts "$repo/$1/config.json" "$base$1/config.json")
  echo "Wrote $1/config.json"
}

generate "$tag"

latest=$(cd "$repo" && ls -d v2.*/ 2>/dev/null | tr -d / | sort -V | tail -1)
if [[ $tag == "$latest" ]]; then
  generate v2
fi

git -C "$repo" status --short
