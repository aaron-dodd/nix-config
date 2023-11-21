#! /usr/bin/env -S nix shell nixpkgs#fzf nixpkgs#jq --command bash
# shellcheck shell=bash

TARGET_WALLPAPER="${1:-}"
WALLPAPERS_FILE="${2:-home/aaron/_common/wallpapers/wallpapers.json}"

if [[ ! -e "$WALLPAPERS_FILE" ]]; then
    echo "wallpapers.json not found in current directory"
    exit 1
fi

if [[ -z "$TARGET_WALLPAPER" ]]; then
    ALL_WALLPAPERS=$(jq -r '.[].name' "$WALLPAPERS_FILE")
    TARGET_WALLPAPER=$(echo "$ALL_WALLPAPERS" | fzf --prompt "Select a wallpaper: ")
fi

RESULT=$(jq --arg name "$TARGET_WALLPAPER" '.[] | select(.name == $name)' "$WALLPAPERS_FILE")

if [[ -z "$RESULT" ]]; then
    echo "No entry found for $TARGET_WALLPAPER"
    exit 1
fi

ID=$(echo "$RESULT" | jq -r ".id")
EXT=$(echo "$RESULT" | jq -r ".ext")
URL="https://i.imgur.com/$ID.$EXT"

xdg-open "$URL"

