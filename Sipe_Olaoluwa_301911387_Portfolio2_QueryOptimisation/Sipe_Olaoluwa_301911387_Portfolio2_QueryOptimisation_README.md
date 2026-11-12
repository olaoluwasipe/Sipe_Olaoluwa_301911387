# Portfolio 2: Query Processing and Optimisation

Six ShopFlow reporting queries, benchmark data, and index experiments on PostgreSQL.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Assumptions

- Query 4 defines low stock as 15 units or fewer. This is a benchmark business rule, not a universal threshold.
- Query 5 treats confirmed, shipped, and delivered orders as completed for this report.
- Query 3 measures successful payment amounts by order month. It is not a full accounting revenue-recognition model.
- The generated timestamps and payment records are synthetic.

## Plan

**Brief:** SQL queries, query results, execution plans, indexing evidence, and a short performance analysis. 7 marks.

**Done**

- [x] Six business queries in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql`.
- [x] Benchmark load: 1,000 extra customers, 20 categories, 2,000 products, 20,000 orders, and three lines per generated order.
- [x] Timestamp and benchmark payment script.
- [x] Experiment 1, customer 500 order history sorted by `orders.id`. Baseline sequential scan 4.090 ms, saved in `baseline.md`. After `idx_orders_customer_id_id_desc`, bitmap heap scan 2.273 ms. The sort stayed because a bitmap scan does not keep index order.
- [x] Experiment 2, the same history sorted by `created_at`. The write-up is in `Experiment2.md`. The saved plans are `Experiment2_before.txt` (6.722 ms, bitmap scan on `idx_orders_customer_id_id_desc`) and `Experiment2_after.txt` (0.879 ms, bitmap scan on `idx_orders_customer_created_at`). The sort stayed. An earlier capture of the same plan shapes took 2.565 ms and 0.895 ms. The `enable_bitmapscan = off` run took 95.582 ms and is left out of the comparison table.
- [x] `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql` creates the three experiment indexes and runs `ANALYZE`.
- [x] Experiment 3, Query 2 top 10 products. Baseline sequential scans of 60,009 order items and 2,009 products, hash aggregate, 58.062 ms in the screenshot. The saved pair is `Experiment3_before.txt` (92.564 ms) and `Experiment3_after.txt` (31.001 ms). `idx_order_items_product_id` was not chosen. Both scans, the hash aggregate, and the buffer counts stayed the same, so the lower time is not counted as an index improvement.
- [x] Result rows for all six queries in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query_results.txt`.
- [x] Run order below.

## Saved screenshots

- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment1_baseline_plan.png` — customer 500 order history sorted by `orders.id`, sequential scan, 4.090 ms.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_order_history_before_created_at_index.png` — the same history sorted by `created_at`, using `idx_orders_customer_id_id_desc`, 2.565 ms.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_benchmark_order_and_payment_counts.png` — 20,005 orders and 20,005 payments after the benchmark load.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query1_and_query2_results.png` — Query 1 order history and Query 2 top 10 products.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query3_and_query4_results.png` — Query 3 monthly revenue and the start of Query 4 low stock.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query4_query5_and_query6_results.png` — the rest of Query 4, Query 5 top customers, and Query 6 payment status.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_bitmapscan_off_and_query2_baseline.png` — `enable_bitmapscan = off` index scan at 95.582 ms, then the Query 2 baseline plan at 58.062 ms.
- `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_bitmapscan_off_and_query2_baseline_plans.png` — the same two plans, framed on the plan text.

## How to run

These steps are for a database that already has the Portfolio 1 schema and seed. Start that database with the Portfolio 1 README. The running ShopFlow database already has the benchmark rows, the spread timestamps, and all three indexes. Do not run the benchmark script or the timestamp `UPDATE` against it again. The benchmark script would insert another copy of the generated rows, and the timestamp script would rewrite `created_at`.

Connection: host `localhost`, port `5433`, database `shopflow`, user `shopflow_user`, password `shopflow_local_only`.

From this folder:

```bash
psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_benchmark_data.sql

psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_add_order_timestamps.sql

psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql

psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql
```

`indexes.sql` uses `CREATE INDEX IF NOT EXISTS`, so it is safe to run on the current database.

`Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query_results.txt` is the saved output of the six queries:

- Query 1 returns 20 orders for Benchmark Customer 0495, newest first.
- Query 2 lists Notebook first, at 179 units, then nine benchmark products at 177 units.
- Query 3 returns 13 months of successful payments, from November 2025 through November 2026. November 2026 is a partial month because the synthetic dates cover the previous 365 days.
- Query 4 returns 113 products with 15 units or fewer. The lowest stock in that result is 5.
- Query 5 returns 10 benchmark customers, each with 20 completed orders. The highest total is 11346945.00.
- Query 6 returns 16,004 successful payments and 4,001 pending payments.
