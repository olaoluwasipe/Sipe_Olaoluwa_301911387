# Portfolio 5: Distributed and Cloud Databases

A ShopFlow primary on port 5433 and one read replica on port 5435.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** replication, sharding, availability, consistency, or a deployment, on the same case study. 6 marks.

**Done**

- [x] `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_design.md`. Primary on port 5433, physical replica on port 5435, asynchronous streaming through slot `shopflow_replica`.
- [x] Data flow: orders, stock changes, and payments write to the primary. Product lists and Query 3 read from the replica.
- [x] The stock check before an order reads the primary. A replica can be behind the latest sale.
- [x] Replica lag and Query 3. With replay paused, November 2026 on the replica stayed at 458 payments and 159780710.00. The primary, after a 1.00 payment on order 1, showed 459 and 159780711.00.
- [x] Availability: a primary failure stops new orders, stock changes, and payments. The replica can still serve product lists and Query 3 from the last log it replayed.
- [x] Second PostgreSQL container `shopflow-postgres-replica`. The replica read and the lag check are saved.
- [x] Run steps below.

## How to run

The primary is the existing `shopflow-postgres` container. The replica is a Compose profile, so the Portfolio 1 `docker compose up -d` command leaves it stopped.

From this folder, prepare the primary. This creates the replication role and the physical slot, adds one `pg_hba.conf` line, and reloads PostgreSQL. It does not restart the primary.

```bash
./Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_setup_primary.sh
```

From `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign`:

```bash
docker compose -f Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml --profile replica up -d shopflow-postgres-replica
```

The first start copies the primary with `pg_basebackup`. A later start keeps that copy and continues streaming.

The replica listens on `localhost:5435`. Database `shopflow`, user `shopflow_user`, password `shopflow_local_only`. The replication user is `shopflow_replicator`, password `shopflow_replica_local_only`. Both passwords are local only, and both are set in the Compose file.

From this folder:

```bash
./Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_show_lag.sh
```

The script reads the product list and Query 3 on the replica, pauses replay, inserts a successful payment of 1.00 for order 1, prints both servers, deletes that payment, and resumes replay.

`Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read.sql` is the same read without the pause:

```bash
psql -h localhost -p 5435 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read.sql
```

Running `show_lag.sh` again inserts another 1.00 payment and deletes it. Each run leaves one unused payment id.

## Saved evidence

`Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read_output.txt` is the run from 12 November 2026.

- `pg_is_in_recovery()` on the replica is true. The receiver status is `streaming` from `shopflow-postgres`, slot `shopflow_replica`. `sync_state` is `async`. Before the pause, `sent_lsn` and `replay_lsn` were both `0/6000060`.
- The replica has 2009 products. Notebook stock is 148, Pen Pack stock is 97, and HDMI Cable stock is 70, matching the Portfolio 3 results.
- Query 3 returns 13 months, November 2025 through November 2026.
- With replay paused, the primary total of successful payments was 5679441615.00 (16005 payments). The replica total was 5679441614.00 (16004 payments). November 2026 moved only on the primary, from 458 payments and 159780710.00 to 459 and 159780711.00.
- After the demo payment was deleted and replay caught up, both servers reported 16004 successful payments and 5679441614.00.
- Payment id 20006 was the demo row and was deleted. The highest payment id left in the table is 20005.
- `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_write.txt`: an `INSERT` into `payments` on port 5435 failed with `cannot execute INSERT in a read-only transaction`.
