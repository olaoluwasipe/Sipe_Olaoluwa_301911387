#!/bin/bash
# Open two psql sessions and interleave their statements.
# Usage: run_sessions.sh lost-update | row-lock

set -euo pipefail

MODE="${1:-}"
if [[ "$MODE" != "lost-update" && "$MODE" != "row-lock" ]]; then
  echo "Usage: $0 lost-update | row-lock" >&2
  exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
export PGPASSWORD=shopflow_local_only
PSQL=(psql -h localhost -p 5433 -U shopflow_user -d shopflow -X -a -v ON_ERROR_STOP=1 --pset=pager=off)

if [[ "$MODE" == "lost-update" ]]; then
  PRODUCT="Pen Pack"
  LABEL="lost_update"
  SELECT_SQL="SELECT stock AS read_stock FROM products WHERE name = '${PRODUCT}' \\gset"
else
  PRODUCT="HDMI Cable"
  LABEL="row_lock"
  SELECT_SQL="SELECT stock AS read_stock FROM products WHERE name = '${PRODUCT}' FOR UPDATE \\gset"
fi

FIFO_A="$(mktemp -u "/tmp/shopflow_${LABEL}_a.XXXXXX")"
FIFO_B="$(mktemp -u "/tmp/shopflow_${LABEL}_b.XXXXXX")"
OUT_A="$DIR/Sipe_Olaoluwa_301911387_Portfolio3_Transactions_${LABEL}_session_a.txt"
OUT_B="$DIR/Sipe_Olaoluwa_301911387_Portfolio3_Transactions_${LABEL}_session_b.txt"

rm -f "$FIFO_A" "$FIFO_B"
mkfifo "$FIFO_A" "$FIFO_B"

"${PSQL[@]}" < "$FIFO_A" > "$OUT_A" 2>&1 &
PID_A=$!
"${PSQL[@]}" < "$FIFO_B" > "$OUT_B" 2>&1 &
PID_B=$!

cleanup() {
  exec 3>&- 2>/dev/null || true
  exec 4>&- 2>/dev/null || true
  kill "$PID_A" "$PID_B" 2>/dev/null || true
  wait "$PID_A" "$PID_B" 2>/dev/null || true
  rm -f "$FIFO_A" "$FIFO_B"
}
trap cleanup EXIT

exec 3>"$FIFO_A"
exec 4>"$FIFO_B"

say() {
  printf '%s\n' "$2" >&"$1"
}

say 3 "\timing on"
say 3 "\echo === Session A: ${MODE}, ${PRODUCT} ==="
say 3 "SHOW transaction_isolation;"
say 3 "BEGIN;"
say 3 "$SELECT_SQL"
say 3 "\echo session_a_read=:read_stock"
sleep 0.6

say 4 "\timing on"
say 4 "\echo === Session B: ${MODE}, ${PRODUCT} ==="
say 4 "SHOW transaction_isolation;"
say 4 "BEGIN;"
say 4 "$SELECT_SQL"
say 4 "\echo session_b_read=:read_stock"
sleep 0.6

if [[ "$MODE" == "lost-update" ]]; then
  say 3 "UPDATE products SET stock = :read_stock - 2 WHERE name = '${PRODUCT}';"
  sleep 0.4
  say 4 "UPDATE products SET stock = :read_stock - 3 WHERE name = '${PRODUCT}';"
  sleep 2
  say 3 "COMMIT;"
  sleep 0.6
  say 4 "COMMIT;"
else
  sleep 2
  say 3 "UPDATE products SET stock = :read_stock - 2 WHERE name = '${PRODUCT}';"
  say 3 "COMMIT;"
  sleep 0.8
  say 4 "\echo session_b_read_after_wait=:read_stock"
  say 4 "UPDATE products SET stock = :read_stock - 3 WHERE name = '${PRODUCT}';"
  say 4 "COMMIT;"
fi

sleep 0.4
say 3 "SELECT name, stock FROM products WHERE name = '${PRODUCT}';"
say 4 "SELECT name, stock FROM products WHERE name = '${PRODUCT}';"
sleep 0.6

say 3 "\q"
say 4 "\q"
exec 3>&-
exec 4>&-

wait "$PID_A"
wait "$PID_B"
trap - EXIT
rm -f "$FIFO_A" "$FIFO_B"
