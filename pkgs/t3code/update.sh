#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
api="https://api.github.com/repos/pingdotgg/t3code/releases?per_page=100"
headers=(-H 'Accept: application/vnd.github+json')
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
release="$(curl -fsSL --retry 3 "${headers[@]}" "$api" | jq -ce '
  [.[] | select(.draft == false and (.tag_name | contains("-nightly.")))]
  | sort_by(.published_at) | last
  | if . == null then error("no nightly release found") else . end
')"
version="$(jq -er '.tag_name | ltrimstr("v")' <<<"$release")"
file="T3-Code-${version}-x86_64.AppImage"
url="$(jq -er --arg file "$file" '.assets[] | select(.name == $file) | .browser_download_url' <<<"$release")"
current="$(jq -er '.version' "$dir/source.json")"

if [[ "$current" == "$version" ]]; then
  echo "t3code: already at $version"
  exit 0
fi

hash="$(nix store prefetch-file --json --hash-type sha256 "$url" | jq -er '.hash')"
tmp="$(mktemp "$dir/source.json.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
jq -n --arg version "$version" --arg url "$url" --arg hash "$hash" \
  '{version: $version, url: $url, hash: $hash}' >"$tmp"
chmod 644 "$tmp"
mv "$tmp" "$dir/source.json"
echo "t3code: $current -> $version"
