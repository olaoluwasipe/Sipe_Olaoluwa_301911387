# Portfolio 2 — Query Optimisation Experiment 2

## Experiment: Customer order history sorted by `created_at`

### 1. Objective

Query 1 returns the orders for customer 500, sorted by `orders.created_at` descending. This experiment checks whether an index on `(customer_id, created_at DESC)` changes that plan.

The statement is Query 1 in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql`.

### 2. Before the `created_at` index

Without `idx_orders_customer_created_at`, PostgreSQL used:

- An index scan on `customers_pkey`.
- A bitmap index scan on `idx_orders_customer_id_id_desc`, then a bitmap heap scan on `orders`.
- A nested loop.
- A separate quicksort on `o.created_at DESC`.

The first capture of that plan took 2.565 ms. The screenshot is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_order_history_before_created_at_index.png`.

The saved repeat is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment2_before.txt`. For that run the `created_at` index was dropped inside a transaction and restored with `ROLLBACK`. The access method was the same. Execution time: 6.722 ms. The sort node reported `shared hit=31`.

### 3. Optimisation

```sql
CREATE INDEX idx_orders_customer_created_at
ON orders (customer_id, created_at DESC);

ANALYZE orders;
```

The statement is in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql`.

### 4. After the index

PostgreSQL used:

- An index scan on `customers_pkey`.
- A bitmap index scan on `idx_orders_customer_created_at`, then a bitmap heap scan on `orders`.
- A nested loop.
- A separate quicksort on `o.created_at DESC`.

The first capture took 0.895 ms. The sort node reported `shared hit=23` and `read=2`.

The saved repeat is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment2_after.txt`. Execution time: 0.879 ms. The sort node reported `shared hit=31`.

### 5. Comparison of the saved plans

These two files were captured on 12 November 2026, one after the other.

| Metric | Before | After |
|---|---:|---:|
| Execution time | 6.722 ms | 0.879 ms |
| Orders access | Bitmap heap scan via `idx_orders_customer_id_id_desc` | Bitmap heap scan via `idx_orders_customer_created_at` |
| Sort | quicksort on `created_at DESC` | quicksort on `created_at DESC` |
| Buffers at the sort | shared hit=31 | shared hit=31 |

The earlier capture of the same two plan shapes took 2.565 ms and then 0.895 ms, about 65.1% less execution time. The saved repeat also dropped, from 6.722 ms to 0.879 ms. On the warm repeat the buffer count did not fall, so that time difference is not a large reduction in pages read.

A separate run set `enable_bitmapscan = off`. PostgreSQL then used an ordered index scan on `idx_orders_customer_created_at` and took 95.582 ms. That plan is slower than the bitmap plan, so it is not included in the table. The screenshot is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_bitmapscan_off_and_query2_baseline.png`.

### 6. Analysis

The new index supplies the customer filter directly. A bitmap heap scan does not keep index order, so the sort on `created_at` stays in the plan even though `created_at` is the second index column.

The ordered index scan was able to walk the index in `created_at` order, and it was much slower on this data. The bitmap plan remains the one selected when the planner is left to choose.

### 7. Conclusion

`idx_orders_customer_created_at` changed which index located customer 500's orders, and both captures were faster than the plan that used `idx_orders_customer_id_id_desc`. The sort remained. Forcing an ordered index scan made the query slower, so that run is not treated as an improvement.
