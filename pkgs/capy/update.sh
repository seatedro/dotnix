#!/usr/bin/env bash
# Bump pkgs/capy/source.json to the latest stable release from Capy's update feed.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="https://downloads.capy.ai/stable"
feed="$(curl -fsSL "$base/latest-linux.yml")"

version="$(sed -n 's/^version: *//p' <<<"$feed" | head -1)"
file="capy-${version}-x86_64.AppImage"
sha512="$(grep -A1 -- "- url: ${file}\$" <<<"$feed" | sed -n 's/^ *sha512: *//p')"

if [[ -z "$version" || -z "$sha512" ]]; then
  echo "capy: could not parse $base/latest-linux.yml" >&2
  exit 1
fi

current="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$dir/source.json")"
if [[ "$current" == "$version" ]]; then
  echo "capy: already at $version"
  exit 0
fi

cat >"$dir/source.json" <<JSON
{
  "version": "${version}",
  "url": "${base}/${file}",
  "hash": "sha512-${sha512}"
}
JSON
echo "capy: $current -> $version"
