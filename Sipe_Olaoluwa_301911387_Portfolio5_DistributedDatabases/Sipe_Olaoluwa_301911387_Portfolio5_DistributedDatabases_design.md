# ShopFlow primary and read replica

ShopFlow uses one PostgreSQL 17 primary and one physical read replica. Both are local Docker containers. The primary is `shopflow-postgres` on port 5433. The replica is `shopflow-postgres-replica` on port 5435.

Replication is asynchronous streaming. The primary commits, then sends the write-ahead log to the replica. On the saved run, `pg_stat_replication.sync_state` was `async`.

The replica was copied with `pg_basebackup` and follows the physical slot `shopflow_replica`. The replication role is `shopflow_replicator`. On the replica, `pg_is_in_recovery()` is true. An `INSERT` into `payments` on port 5435 failed with `cannot execute INSERT in a read-only transaction`.

## Data flow

Orders, stock changes, and payments are written to the primary.

- An order writes `orders` and `order_items` on the primary.
- A stock change writes `products.stock` and `inventory_logs` on the primary, in the same transaction as the order. That is the Portfolio 3 order transaction.
- A payment writes `payments` on the primary.

Product lists and sales reports are read from the replica. The saved replica read lists products and runs Query 3. Query 3 is monthly revenue: `SUM(payments.amount)` for `payments.status = 'successful'`, grouped by `DATE_TRUNC('month', orders.created_at)`.

## Stock check

The stock check before an order reads the primary. Portfolio 3 reads `products.stock` in the same transaction as the stock update. A replica can be behind the latest sale, so a stock figure from the replica can still count units the primary has already sold. The order transaction stays on port 5433.

## Replica lag and Query 3

Query 3 on the replica sums the successful payments that the replica has replayed. A successful payment committed on the primary stays out of that month's revenue until the replica replays it. The payment count for the month is short by the same rows.

The saved run paused replay, then inserted a successful payment of 1.00 on order 1. Order 1's `created_at` is in November 2026.

| Server | November 2026 payments | November 2026 revenue |
|---|---:|---:|
| Primary | 459 | 159780711.00 |
| Replica | 458 | 159780710.00 |

The successful-payment total was 5679441615.00 on the primary and 5679441614.00 on the replica. The replica was short by 1.00.

That demo payment was deleted, and replay was resumed. Both servers then reported 16004 successful payments and 5679441614.00. Payment id 20006 was the demo row, so that id is absent. The highest payment id still in the table is 20005.

Before the pause, `sent_lsn` and `replay_lsn` were both `0/6000060`.

## Availability

If the primary is down, new orders, stock changes, and payments wait until the primary is accepting connections again. Those statements are sent to port 5433.

The replica can still serve product lists and Query 3 from the last write-ahead log it has replayed. The saved read returned the product list and 13 monthly revenue rows while `pg_is_in_recovery()` was true.

This run left out promotion of the replica, automatic failover, synchronous replication, sharding, and a cloud deployment. The slot `shopflow_replica` keeps write-ahead log on the primary until the replica replays it. A replica that stays stopped leaves that log on the primary.

## What the replica read showed

`pg_stat_wal_receiver` reported status `streaming`, sender `shopflow-postgres` port 5432, slot `shopflow_replica`.

The replica has 2009 products. The first rows are the sample catalogue. Notebook stock is 148, Pen Pack stock is 97, and HDMI Cable stock is 70. Those stocks are the ones left by the Portfolio 3 runs, so the replica holds the current primary data.

Query 3 on the replica returned 13 months, November 2025 through November 2026. November 2026 is a partial month. Before the pause it was 458 successful payments and 159780710.00.
