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

**Still to do**

- [ ] Move the `(customer_id, created_at DESC)` index write-up into `Experiment2.md`. That file currently repeats Experiment 1. The 0.895 ms result is an extra section at the bottom of `Experiment1.md`.
- [ ] Save the before and after `EXPLAIN (ANALYZE, BUFFERS)` text for the `created_at` index.
- [ ] Leave the `enable_bitmapscan = off` run out of the improvement table. That plan took 95.582 ms, which is slower than the bitmap plan.
- [ ] Add `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql` with the `CREATE INDEX` statements and `ANALYZE`.
- [ ] Second optimisation on Query 2, top 10 products. Baseline already captured: sequential scans of about 60,009 order items and 2,009 products, hash aggregate, 58.062 ms. Test an index on `order_items (product_id)`. Save plans, access method, and buffer counts.
- [ ] Save the result rows for all six queries.
- [ ] Write the run order below. Keep the assumptions above.

## How to run

Run order, once the index script exists:

1. Portfolio 1 schema and seed.
2. `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_benchmark_data.sql`.
3. `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_add_order_timestamps.sql`. `orders.created_at` already exists from the Portfolio 1 schema. This script spreads those timestamps and inserts benchmark payments. The `ADD COLUMN` uses `IF NOT EXISTS`.
4. The index script.
5. The six queries in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql`.

Fill in the connection command and what each saved result shows when those runs are written up.
