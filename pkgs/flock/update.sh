#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
api="https://api.github.com/repos/seatedro/t3code/releases?per_page=100"
headers=(-H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28')
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
release="$(curl -fsSL --retry 3 "${headers[@]}" "$api" | jq -ce '
  [.[] | select(.draft == false and (.tag_name | test("^v[0-9].*-nightly\\.[0-9]{8}\\.[0-9]+$")))]
  | sort_by(.published_at) | last
  | if . == null then error("no Flock nightly release found") else . end
')"
version="$(jq -er '.tag_name | ltrimstr("v")' <<<"$release")"
tmp="$(mktemp "$dir/source.json.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
jq -n --arg version "$version" '{version: $version, sources: {}}' >"$tmp"

for system in x86_64-linux aarch64-linux; do
  case "$system" in
    x86_64-linux) arch=x86_64 ;;
    aarch64-linux) arch=arm64 ;;
  esac
  file="Flock-${version}-${arch}.AppImage"
  url="$(jq -er --arg file "$file" '
    [.assets[] | select(.name == $file) | .browser_download_url]
    | if length == 1 then .[0] else error("missing or ambiguous asset: " + $file) end
  ' <<<"$release")"
  if [[ "$url" != "https://github.com/seatedro/t3code/releases/download/v${version}/${file}" ]]; then
    echo "flock: unexpected asset URL: $url" >&2
    exit 1
  fi
  hash="$(jq -r --arg system "$system" --arg url "$url" '
    if .sources[$system].url == $url then .sources[$system].hash // empty else empty end
  ' "$dir/source.json")"
  if [[ -z "$hash" ]]; then
    hash="$(nix store prefetch-file --json --hash-type sha256 "$url" | jq -er '.hash')"
  fi
  content="$(jq --arg system "$system" --arg url "$url" --arg hash "$hash" \
    '.sources[$system] = {url: $url, hash: $hash}' "$tmp")"
  printf '%s\n' "$content" >"$tmp"
done

if cmp -s "$tmp" "$dir/source.json"; then
  echo "flock: already at $version"
  exit 0
fi
current="$(jq -er '.version' "$dir/source.json")"
chmod 644 "$tmp"
mv "$tmp" "$dir/source.json"
echo "flock: $current -> $version"
