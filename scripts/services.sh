#!/usr/bin/env bash
set -euo pipefail
PGDATA=$RUNNER_TEMP/pg
case "$1" in
  start)
    initdb -D "$PGDATA" > /dev/null
    pg_ctl -D "$PGDATA" -o "-k $RUNNER_TEMP -c listen_addresses=''" -l "$RUNNER_TEMP/pg.log" start
    ;;
  test)
    for _ in $(seq 20); do psql -h "$RUNNER_TEMP" -d postgres -c 'select version()' > /dev/null; done
    sleep 30
    ;;
  stop)
    pg_ctl -D "$PGDATA" stop -m fast
    ;;
esac
