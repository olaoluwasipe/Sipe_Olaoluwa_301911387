#!/bin/sh
# Show a replica read, then pause replay so Query 3 on the replica misses one payment.
# The demo payment is deleted before replay resumes. The script removes it on exit as well.
set -eu

cd "$(dirname "$0")"

export PGPASSWORD="${PGPASSWORD:-shopflow_local_only}"
READ_SQL="Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read.sql"

paused=0
pay_id=

psql_primary() {
  psql -h localhost -p 5433 -U shopflow_user -d shopflow -v ON_ERROR_STOP=1 "$@"
}

psql_replica() {
  psql -h localhost -p 5435 -U shopflow_user -d shopflow -v ON_ERROR_STOP=1 "$@"
}

cleanup() {
  status=$?
  if [ -n "$pay_id" ]; then
    psql_primary -c "DELETE FROM payments WHERE id = ${pay_id};" || true
    pay_id=
  fi
  if [ "$paused" -eq 1 ]; then
    psql_replica -c "SELECT pg_wal_replay_resume();" || true
    paused=0
  fi
  exit "$status"
}

trap cleanup EXIT

echo "=== Primary replication status ==="
psql_primary -c "SELECT application_name, state, sync_state, sent_lsn, replay_lsn, replay_lag
FROM pg_stat_replication
WHERE application_name = 'shopflow_replica';"

echo "=== Replica read: recovery, product list, Query 3 ==="
psql_replica -f "$READ_SQL"

echo "=== Pause WAL replay on the replica ==="
psql_replica -c "SELECT pg_wal_replay_pause();"
paused=1

i=0
while [ "$i" -lt 25 ]; do
  is_paused=$(psql_replica -q -tA -c "SELECT pg_is_wal_replay_paused();")
  if [ "$is_paused" = "t" ]; then
    break
  fi
  i=$((i + 1))
  sleep 0.2
done

if [ "$is_paused" != "t" ]; then
  echo "Replay did not pause."
  exit 1
fi

echo "=== Insert a 1.00 successful payment for order 1 on the primary ==="
pay_id=$(psql_primary -q -tA -c "INSERT INTO payments (order_id, amount, status)
VALUES (1, 1.00, 'successful')
RETURNING id;")
echo "Demo payment id: ${pay_id}"

echo "=== Successful payment total while replay is paused ==="
psql_primary -c "SELECT 'primary' AS server, COUNT(*) AS successful_payments, SUM(amount) AS total_amount
FROM payments
WHERE status = 'successful';"
psql_replica -c "SELECT 'replica' AS server, COUNT(*) AS successful_payments, SUM(amount) AS total_amount
FROM payments
WHERE status = 'successful';"

echo "=== Query 3 row for order 1's month, primary then replica ==="
MONTH_SQL="SELECT 'primary' AS server,
    DATE_TRUNC('month', o.created_at) AS revenue_month,
    COUNT(p.id) AS successful_payment_count,
    SUM(p.amount) AS monthly_revenue
FROM orders o
JOIN payments p ON p.order_id = o.id
WHERE p.status = 'successful'
  AND DATE_TRUNC('month', o.created_at) = (
      SELECT DATE_TRUNC('month', created_at) FROM orders WHERE id = 1
  )
GROUP BY DATE_TRUNC('month', o.created_at);"

psql_primary -c "$MONTH_SQL"
psql_replica -c "SELECT 'replica' AS server,
    DATE_TRUNC('month', o.created_at) AS revenue_month,
    COUNT(p.id) AS successful_payment_count,
    SUM(p.amount) AS monthly_revenue
FROM orders o
JOIN payments p ON p.order_id = o.id
WHERE p.status = 'successful'
  AND DATE_TRUNC('month', o.created_at) = (
      SELECT DATE_TRUNC('month', created_at) FROM orders WHERE id = 1
  )
GROUP BY DATE_TRUNC('month', o.created_at);"

primary_total=$(psql_primary -q -tA -c "SELECT SUM(amount) FROM payments WHERE status = 'successful';")
replica_total=$(psql_replica -q -tA -c "SELECT SUM(amount) FROM payments WHERE status = 'successful';")

if [ "$primary_total" = "$replica_total" ]; then
  echo "Lag check failed: totals match while replay is paused."
  exit 1
fi

echo "Primary total ${primary_total}; replica total ${replica_total}."

echo "=== Delete the demo payment and resume replay ==="
psql_primary -c "DELETE FROM payments WHERE id = ${pay_id};"
pay_id=
psql_replica -c "SELECT pg_wal_replay_resume();"
paused=0

i=0
caught=f
while [ "$i" -lt 25 ]; do
  caught=$(psql_primary -q -tA -c "SELECT EXISTS (
    SELECT 1
    FROM pg_stat_replication
    WHERE application_name = 'shopflow_replica'
      AND state = 'streaming'
      AND replay_lsn = sent_lsn
  );")
  if [ "$caught" = "t" ]; then
    break
  fi
  i=$((i + 1))
  sleep 0.4
done

if [ "$caught" != "t" ]; then
  echo "Replica did not catch up after resume."
  exit 1
fi

echo "=== Successful payment total after replay catches up ==="
psql_primary -c "SELECT 'primary' AS server, COUNT(*) AS successful_payments, SUM(amount) AS total_amount
FROM payments
WHERE status = 'successful';"
psql_replica -c "SELECT 'replica' AS server, COUNT(*) AS successful_payments, SUM(amount) AS total_amount
FROM payments
WHERE status = 'successful';"

primary_total=$(psql_primary -q -tA -c "SELECT SUM(amount) FROM payments WHERE status = 'successful';")
replica_total=$(psql_replica -q -tA -c "SELECT SUM(amount) FROM payments WHERE status = 'successful';")

if [ "$primary_total" != "$replica_total" ]; then
  echo "Catch-up check failed: totals differ after replay."
  exit 1
fi

echo "Both servers report ${primary_total} after replay."
echo "Demo payment removed. Payment ids are not reused, so one id is skipped."
