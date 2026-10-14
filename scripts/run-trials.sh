#!/usr/bin/env bash
# Usage: run-trials.sh <owner/repo> [n]
set -euo pipefail
REPO=${1:?usage: run-trials.sh <owner/repo> [n]}
N=${2:-10}

run_and_wait() {
  local wf=$1 before id
  before=$(gh run list -R "$REPO" -w "$wf" -L 1 --json databaseId -q '.[0].databaseId // 0')
  gh workflow run "$wf" -R "$REPO"
  until id=$(gh run list -R "$REPO" -w "$wf" -L 1 --json databaseId -q '.[0].databaseId') && [ "$id" != "$before" ]; do
    sleep 5
  done
  gh run watch "$id" -R "$REPO" --exit-status > /dev/null || echo "run $id failed"
  echo "$wf $id"
}

for _ in $(seq "$N"); do
  run_and_wait baseline.yml
  run_and_wait quick-install.yml
done
