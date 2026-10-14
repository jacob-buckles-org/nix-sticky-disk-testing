#!/usr/bin/env bash
set -uo pipefail
df -h /nix
echo "inodes: $(df --output=iused /nix | tail -1)"
echo "store paths: $(find /nix/store -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)"
