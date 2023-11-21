#! /usr/bin/env -S nix shell nixpkgs#curl nixpkgs#jq --command bash
# shellcheck shell=bash

TARGET_LINK="${1:-}"
TARGET_NAME="${2:-}"
WALLPAPERS_FILE="${3:-./home/aaron/_common/wallpapers/wallpapers.json}"

if [[ -z "$TARGET_LINK" ]]; then
    echo "You must provide an imgur link."
    exit 1
fi

if [[ -z "$TARGET_NAME" ]]; then
    echo "You must provide an image name."
    exit 1
fi

TARGET_LINK_EXT="${TARGET_LINK##*.}"
TARGET_LINK_ID="$(basename "$TARGET_LINK" ".$TARGET_LINK_EXT")"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

OBJECT=$(
    jq -n --arg ext "$TARGET_LINK_EXT" \
       --arg id "$TARGET_LINK_ID" \
       --arg sha256 "$(nix-prefetch-url "$TARGET_LINK")" \
       --arg name "$TARGET_NAME" \
       '{ ext: $ext, id: $id, name: $name, sha256: $sha256 }')

jq ". += [$OBJECT]" "$WALLPAPERS_FILE" > "$TEMP_DIR/temp.json"
mv "$TEMP_DIR/temp.json" "$WALLPAPERS_FILE"

