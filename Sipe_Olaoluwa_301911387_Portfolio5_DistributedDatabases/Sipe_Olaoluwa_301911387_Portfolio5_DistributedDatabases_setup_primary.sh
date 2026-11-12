#!/bin/sh
# Prepare the running primary for one physical read replica.
# Does not restart PostgreSQL. The data directory is left in place.
set -eu

cd "$(dirname "$0")"

export PGPASSWORD="${PGPASSWORD:-shopflow_local_only}"

psql -h localhost -p 5433 -U shopflow_user -d shopflow -v ON_ERROR_STOP=1 \
  -f Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_setup_primary.sql

docker exec shopflow-postgres sh -c \
  'grep -qxF "host replication shopflow_replicator all scram-sha-256" /var/lib/postgresql/data/pg_hba.conf || echo "host replication shopflow_replicator all scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf'

psql -h localhost -p 5433 -U shopflow_user -d shopflow -v ON_ERROR_STOP=1 \
  -c "SELECT pg_reload_conf();"
