#!/usr/bin/env bash
set -euo pipefail
TARGET_GB=${1:?usage: fill-store.sh <gb>}
FILES_PER_PATH=${FILES_PER_PATH:-200}
MAX_FILE_KB=${MAX_FILE_KB:-64}
BATCH=${BATCH:-250}

nix build --no-link "$NIXPKGS#postgresql_17" "$NIXPKGS#postgresql_15" "$NIXPKGS#go" \
  "$NIXPKGS#nodejs" "$NIXPKGS#python3" "$NIXPKGS#docker-compose" "$NIXPKGS#rustc"

used_gb() { du -sx --block-size=1G /nix | cut -f1; }
work=$(mktemp -d)
i=0
while [ "$(used_gb)" -lt "$TARGET_GB" ]; do
  python3 - "$work" "$i" "$BATCH" "$FILES_PER_PATH" "$MAX_FILE_KB" <<'PY'
import os, random, sys
work, start, batch, files, max_kb = sys.argv[1], *map(int, sys.argv[2:])
for p in range(start, start + batch):
    d = os.path.join(work, f"filler-{p}")
    os.makedirs(os.path.join(d, "lib"), exist_ok=True)
    for f in range(files):
        sub = "lib" if f % 2 else ""
        with open(os.path.join(d, sub, f"f{f}"), "wb") as fh:
            fh.write(os.urandom(random.randint(1, max_kb) * 1024))
PY
  nix-store --add "$work"/filler-* > /dev/null
  rm -rf "$work"/filler-*
  i=$((i + BATCH))
  echo "added $i paths, store at $(used_gb)G"
done
scripts/store-stats.sh
