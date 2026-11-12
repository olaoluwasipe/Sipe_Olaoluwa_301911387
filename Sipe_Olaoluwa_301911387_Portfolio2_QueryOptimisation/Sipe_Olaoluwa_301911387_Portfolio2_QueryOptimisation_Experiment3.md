# Portfolio 2 — Query Optimisation Experiment 3

## Experiment: An index on `order_items (product_id)` for the top 10 products

### 1. Objective

Query 2 totals units and sales value for every product, then returns the top 10. The test was an index on `order_items (product_id)`.

The statement is Query 2 in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql`.

### 2. Baseline

The first capture is in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_bitmapscan_off_and_query2_baseline.png`. PostgreSQL used:

- A sequential scan of `order_items`, about 60,009 rows, `shared hit=501`.
- A sequential scan of `products`, 2,009 rows, `shared hit=21`.
- A hash join, a hash aggregate, and a top-N heapsort.
- Execution time 58.062 ms. The limit node reported `shared hit=522`.

The plan saved immediately before the new index is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment3_before.txt`. The nodes are the same. Execution time on that run: 92.564 ms. The limit node reported `shared hit=525`.

### 3. Optimisation

```sql
CREATE INDEX idx_order_items_product_id
ON order_items (product_id);

ANALYZE order_items;
ANALYZE products;
```

The statement is in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql`. The index was created on the running database before the after plan was captured.

### 4. After the index

The saved plan is `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment3_after.txt`. PostgreSQL kept the same nodes:

- Sequential scan of `order_items`, 60,009 rows, `shared hit=501`.
- Sequential scan of `products`, 2,009 rows, `shared hit=21`.
- Hash join, hash aggregate (867 groups, 625 kB), top-N heapsort (26 kB).
- Execution time 31.001 ms. The limit node reported `shared hit=525`.

`idx_order_items_product_id` does not appear in the plan.

### 5. Comparison

| Metric | Before | After |
|---|---|---|
| Execution time | 92.564 ms | 31.001 ms |
| `order_items` access | Sequential scan, 60,009 rows, shared hit=501 | Sequential scan, 60,009 rows, shared hit=501 |
| `products` access | Sequential scan, 2,009 rows, shared hit=21 | Sequential scan, 2,009 rows, shared hit=21 |
| Aggregate | Hash aggregate, 867 groups | Hash aggregate, 867 groups |
| Use of `idx_order_items_product_id` | Index not present | Index present and not chosen |

The earlier screenshot of this baseline took 58.062 ms with the same sequential scans and `shared hit=522`.

### 6. Analysis

Query 2 has to read every order item to compute `SUM(quantity)` and `SUM(quantity * price)`. An index on `product_id` can find the lines for one product. It does not remove the need to visit every line when the report ranks all products.

The planner kept the sequential scan, the hash join, and the hash aggregate. The buffer counts on those scans are the same in the before and after files. The lower time on the after run fits a warm cache. It is not a change of access method, so it is not counted as an improvement from the index.

### 7. Conclusion

`idx_order_items_product_id` did not change how Query 2 reads `order_items` or `products`. The full aggregation still uses sequential scans. The index remains in `indexes.sql` so a fresh database can reproduce this after plan.
