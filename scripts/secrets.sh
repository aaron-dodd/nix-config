#! /usr/bin/env nix-shell
#! nix-shell -i bash -p age sops
# shellcheck shell=bash

set -euo pipefail

TARGET_OPTION="${1:-}"
TARGET_ENVIRONMENT="${2:-hosts}"
TARGET_MACHINE="${3:-$(hostname)}"

if [[ "$TARGET_OPTION" == "updatekeys" ]]; then
    sops updatekeys "secrets/$TARGET_ENVIRONMENT/$TARGET_MACHINE/secrets.yaml"
elif [[ "$TARGET_OPTION" == "edit" ]]; then
    sops "secrets/$TARGET_ENVIRONMENT/$TARGET_MACHINE/secrets.yaml"
fi

