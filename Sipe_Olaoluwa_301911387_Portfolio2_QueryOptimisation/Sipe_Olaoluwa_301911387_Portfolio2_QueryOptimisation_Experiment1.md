# Portfolio 2 — Query Optimisation Experiment 1

## Experiment: Optimising Customer Order Retrieval

### 1. Objective

The objective was to investigate how indexing affects the performance of retrieving orders belonging to a particular customer.

The query joins the `orders` and `customers` tables, filters orders using `customer_id`, and sorts the results by descending order ID.

### 2. Baseline

Before introducing the index, PostgreSQL used:

- An index scan on `customers_pkey`.
- A sequential scan on `orders`.
- A nested loop join.
- A separate sort operation.

The sequential scan examined 20,005 order records and removed 19,985 records that did not match the specified customer.

**Baseline execution time: 4.090 ms.**

### 3. Optimisation

The following composite index was created:

```sql
CREATE INDEX idx_orders_customer_id_id_desc
ON orders (customer_id, id DESC);

ANALYZE orders;
```

The index was designed to support filtering by customer and ordering by descending order ID.

### 4. Results after optimisation

PostgreSQL changed its execution strategy and used:

- An index scan on the customer primary key.
- A bitmap index scan on `idx_orders_customer_id_id_desc`.
- A bitmap heap scan on `orders`.
- A nested loop join.
- A separate sort operation.

**Execution time after indexing: 2.273 ms.**

### 5. Performance comparison

| Metric | Before | After |
|---|---:|---:|
| Execution time | 4.090 ms | 2.273 ms |
| Order access method | Sequential scan | Bitmap heap scan |
| Index usage | Customer primary key only | Customer primary key and new composite index |
| Shared buffer activity | 312 hits | 23 hits, 2 reads |

The execution time decreased by approximately 44.4%.

### 6. Analysis

The index reduced the amount of unnecessary table scanning required to locate a customer's orders.

PostgreSQL selected a bitmap scan instead of a regular ordered index scan. Consequently, the separate sort operation remained in the execution plan despite the composite index containing the ordering column.

This demonstrates that query optimisation depends on the database query planner's cost estimates and the selected execution strategy, rather than simply the presence of an index.

### 7. Conclusion

The experiment demonstrated that adding an appropriate index can improve query performance by reducing unnecessary data access.

The recorded execution time decreased from 4.090 ms to 2.273 ms. However, execution times can vary due to caching and system activity, so execution plans and buffer statistics should also be considered when evaluating optimisation.

### Additional Optimisation: Customer and Order Date Index

A second composite index was introduced to support the customer order-history query:

```sql
CREATE INDEX idx_orders_customer_created_at
ON orders (customer_id, created_at DESC);

ANALYZE orders;
```

The index was designed to support filtering by customer ID and ordering by order creation date.

**Execution result:**

- Previous execution time: 2.565 ms
- New execution time: 0.895 ms
- Execution-time reduction: approximately 65.1%

PostgreSQL used a Bitmap Index Scan on the new index, followed by a Bitmap Heap Scan on the orders table.

A separate sort operation remained in the execution plan because bitmap heap scans do not preserve index ordering.

The result demonstrates that an index can improve data retrieval even when the query planner does not eliminate every operation in the execution plan.

The benchmark is based on individual recorded executions, so the measured improvement should not be interpreted as a guaranteed performance gain under all workloads.