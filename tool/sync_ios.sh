#!/bin/sh
# Copies AdwellSDK at a release tag into ios/vendor/AdwellSDK for CocoaPods
# builds (ADR 0002 D9). The copy is generated; never edit it by hand.
#
#   tool/sync_ios.sh ../adwell-ios 0.1.0
set -eu

src=${1:?path to an adwell-ios checkout}
tag=${2:?release tag, e.g. 0.1.0}
root=$(cd "$(dirname "$0")/.." && pwd)
dest="$root/ios/vendor/AdwellSDK"

commit=$(git -C "$src" rev-parse --verify "refs/tags/$tag^{commit}")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$src" archive "$tag" Sources/AdwellSDK | tar -x -C "$tmp"

rm -rf "$dest"
mkdir -p "$dest"
cp "$tmp"/Sources/AdwellSDK/* "$dest"/
printf '%s %s\n' "$tag" "$commit" > "$dest/VERSION"
echo "ios/vendor/AdwellSDK <- adwell-ios $tag ($commit)"
