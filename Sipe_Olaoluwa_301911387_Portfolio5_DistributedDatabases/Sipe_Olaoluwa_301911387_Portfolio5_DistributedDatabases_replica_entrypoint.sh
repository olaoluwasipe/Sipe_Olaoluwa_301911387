#!/bin/sh
# Start PostgreSQL as a physical standby of shopflow-postgres.
# An empty data directory is filled with pg_basebackup. A later start keeps that copy.
set -eu

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PRIMARY_HOST="${PRIMARY_HOST:-shopflow-postgres}"
REPLICATION_USER="${REPLICATION_USER:-shopflow_replicator}"
REPLICATION_PASSWORD="${REPLICATION_PASSWORD:-shopflow_replica_local_only}"

mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Replica data directory is empty. Taking a base backup from ${PRIMARY_HOST}."
  attempt=1
  while [ "$attempt" -le 30 ]; do
    find "$PGDATA" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    if PGPASSWORD="$REPLICATION_PASSWORD" gosu postgres pg_basebackup \
      -h "$PRIMARY_HOST" \
      -p 5432 \
      -U "$REPLICATION_USER" \
      -D "$PGDATA" \
      -Fp -Xs -P -R \
      --slot=shopflow_replica; then
      break
    fi
    echo "Base backup attempt ${attempt} failed. Retrying in 2 seconds."
    attempt=$((attempt + 1))
    sleep 2
  done

  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Base backup did not finish."
    exit 1
  fi

  gosu postgres sh -c "cat >> '$PGDATA/postgresql.auto.conf'" <<EOF
primary_conninfo = 'host=${PRIMARY_HOST} port=5432 user=${REPLICATION_USER} password=${REPLICATION_PASSWORD} application_name=shopflow_replica'
primary_slot_name = 'shopflow_replica'
hot_standby = on
EOF
fi

unset PGPASSWORD
exec /usr/local/bin/docker-entrypoint.sh postgres
