#!/usr/bin/env bash
set -euo pipefail
TARGET_GB=${1:?usage: fill-store.sh <gb>}
FILES_PER_PATH=${FILES_PER_PATH:-200}
FILE_KB=${FILE_KB:-256}
BATCH=${BATCH:-200}

nix build --no-link "$NIXPKGS#postgresql_17" "$NIXPKGS#postgresql_15" "$NIXPKGS#go" \
  "$NIXPKGS#nodejs" "$NIXPKGS#python3" "$NIXPKGS#docker-compose" "$NIXPKGS#rustc"

used_gb() { du -sx --block-size=1G /nix | cut -f1; }
work=$(mktemp -d)
i=0
while [ "$(used_gb)" -lt "$TARGET_GB" ]; do
  paths=()
  for _ in $(seq "$BATCH"); do
    d="$work/filler-$RANDOM$RANDOM-$i"
    mkdir -p "$d"
    for f in $(seq "$FILES_PER_PATH"); do
      head -c "$((FILE_KB * 1024))" /dev/urandom > "$d/f$f"
    done
    paths+=("$d")
    i=$((i + 1))
  done
  nix-store --add "${paths[@]}" > /dev/null
  rm -rf "${paths[@]}"
  echo "added $i paths, store at $(used_gb)G"
done
scripts/store-stats.sh
