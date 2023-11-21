#!/usr/bin/env bash
# btrfs-diff.sh
set -euo pipefail

MNTPOINT=$(mktemp -d)
sudo mkdir --parents "$MNTPOINT"
sudo mount -o subvol=/ "/dev/disk/by-partlabel/disk-main-root" "$MNTPOINT"

OLD_TRANSID=$(sudo btrfs subvolume find-new "$MNTPOINT/root-blank" 9999999)
OLD_TRANSID=${OLD_TRANSID#transid marker was }

sudo btrfs subvolume find-new "$MNTPOINT/root" "$OLD_TRANSID" |
    sed '$d' | cut -f17- -d' ' | sort | uniq |
    while read -r path; do
        path="/$path"
        if [ -L "$path" ]; then
            : # The path is a symbolic link, so is probably handled by NixOS already
        elif [ -d "$path" ]; then
            : # The path is a directory, ignore
        else
            echo "$path"
        fi
    done

sudo umount "$MNTPOINT"
sudo rm -rf "$MNTPOINT"

