#!/usr/bin/env bash
# Usage: compare.sh <owner/repo> [n]
set -euo pipefail
REPO=${1:?usage: compare.sh <owner/repo> [n]}
N=${2:-10}

for wf in baseline.yml quick-install.yml; do
  echo "== $wf"
  gh run list -R "$REPO" -w "$wf" -s success -L "$N" --json databaseId -q '.[].databaseId' |
  while read -r id; do
    gh api "repos/$REPO/actions/runs/$id/jobs" -q '.jobs[].steps[]
      | select(.conclusion == "success")
      | [.name, ((.completed_at | fromdate) - (.started_at | fromdate))] | @tsv'
  done |
  awk -F'\t' '{v[$1] = v[$1] " " $2} END {for (k in v) print k "\t" v[k]}' |
  while IFS=$'\t' read -r name vals; do
    sorted=$(tr ' ' '\n' <<<"$vals" | grep . | sort -n)
    n=$(wc -l <<<"$sorted")
    p50=$(sed -n "$(( (n + 1) / 2 ))p" <<<"$sorted")
    p90=$(sed -n "$(( (n * 9 + 9) / 10 ))p" <<<"$sorted")
    printf '%-36s n=%-3s p50=%5ss p90=%5ss\n' "$name" "$n" "$p50" "$p90"
  done
done
