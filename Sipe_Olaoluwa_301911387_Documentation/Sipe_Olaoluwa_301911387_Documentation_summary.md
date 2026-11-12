# ShopFlow: summary of the five portfolios

**Student:** Olaoluwa Sipe
**Student ID:** 301911387
**Course:** MIT 8103, Advanced Database Systems

ShopFlow is one sample online shop, used for every portfolio. PostgreSQL 17 stores customers, categories, products, orders, order items, payments, and inventory logs. MongoDB 7 stores a customer order-history document for reading. The same PostgreSQL database then runs as a primary on port 5433 and a read replica on port 5435. The repository is [https://github.com/olaoluwasipe/Sipe_Olaoluwa_301911387](https://github.com/olaoluwasipe/Sipe_Olaoluwa_301911387). Each portfolio folder has a README, the scripts, and the saved output. This summary names those files. It does not copy the screenshots.

## 1. Database design

The schema has seven tables, with primary keys, foreign keys, checks, and a unique `(order_id, product_id)` constraint. The script is `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_schema.sql`. The rendered diagram is `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.png`. After the seed, the shop had 5 customers, 5 categories, 9 products, 5 orders, 9 order items, 5 payments, and 9 inventory logs. That count is `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_seed_row_counts.png`.

The tables are in first, second, and third normal form. A column holds one value, an order does not store a list of products, and the lines live in `order_items`. `orders.total` is a stored copy of `SUM(quantity * price)`. The copy is there so an order can be read without summing its lines. Portfolio 3 writes that total in the same transaction as the line items. The note is `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_Normalization.md`.

## 2. Query processing

Six queries run on a benchmark load of 1,000 extra customers, 2,000 products, and 20,000 orders. The result rows are in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query_results.txt`. Query 3 sums successful payments by the month of `orders.created_at`.

Experiment 1 reads one customer's orders sorted by order id. A sequential scan took 4.090 ms. After `idx_orders_customer_id_id_desc`, a bitmap heap scan took 2.273 ms. The sort stayed, because a bitmap scan does not keep index order. See `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment1.md`.

Experiment 2 sorts that history by `created_at`. The saved plans go from 6.722 ms to 0.879 ms after `idx_orders_customer_created_at`, and the sort remains. See `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment2.md`.

Experiment 3 adds `idx_order_items_product_id` for the top-10 products query. Both plans still sequentially scan `order_items` (60,009 rows) and `products`. The new index does not appear. The time fell from 92.564 ms to 31.001 ms with the same scan buffer counts. See `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment3.md`.

## 3. Transactions

The isolation level is read committed. `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql` inserts Alice Johnson's Notebook order 20006, reduces Notebook stock from 150 to 148, writes an inventory log, sets `orders.total` to 2400.00, and commits. `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql` orders 100,000 notebooks, fails `products_stock_check`, and rolls back. Stock stays 148 and the order count stays 20006.

Two sessions both read Pen Pack stock as 100. Session A writes 98 and commits. Session B writes 97. The reduction of 2 is lost. Session B waited 2026 ms. The same pattern on HDMI Cable uses `SELECT ... FOR UPDATE`. Session B waited 2615 ms, read 73, and the final stock is 70, which is 75 - 2 - 3. The notes are `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md`.

## 4. Document model

MongoDB stores one document per customer, with orders and line items embedded. The seed is the five sample customers, orders 1 to 5, and Alice's order 20006. The benchmark orders are not copied. Stock, payments, and inventory logs stay in PostgreSQL, because those writes need a transaction that can roll back. Alice's two stored order totals sum to 34400. The confirmed orders are 1, 4, and 20006. See `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_model.md` and `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_query_output.txt`.

## 5. Primary and read replica

`shopflow-postgres` on port 5433 is the primary. `shopflow-postgres-replica` on port 5435 is a physical standby, using asynchronous streaming and the slot `shopflow_replica`. Orders, stock changes, and payments are written to the primary. Product lists and Query 3 are read from the replica. The stock check before an order reads the primary, because a replica can be behind the latest sale.

On 12 November 2026 the replica was in recovery and streaming. With replay paused, a successful payment of 1.00 on order 1 changed November 2026 on the primary from 458 payments and 159780710.00 to 459 payments and 159780711.00. The replica stayed at 458 payments and 159780710.00. After that payment was deleted and replay resumed, both servers reported 16004 successful payments and 5679441614.00. An insert into `payments` on port 5435 failed with `cannot execute INSERT in a read-only transaction`. This run did not promote the replica. See `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_design.md` and `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read_output.txt`.

## Reflection

PostgreSQL holds the records that have to change together: the order, its lines, the stock, the inventory log, and the stored total. MongoDB holds a history document so that one customer read does not join those tables. The replica serves product lists and monthly revenue. The stock check stays on the primary.

The runs changed the write-ups. In Experiment 1 the index was used and the sort was still in the plan, so the note records the bitmap scan. In Experiment 3 the product index was present and unused. The lower time is described as a warm cache, and the sequential scans are the result. Under read committed, both Pen Pack sessions read 100 and the final stock was 97. That lost update is the concurrency example. HDMI Cable repeats the pattern with `FOR UPDATE`, and both reductions remain. Query 3 on the replica missed one committed payment until replay caught up, so the design note sends the stock check to port 5433.

## References

PostgreSQL Global Development Group. *PostgreSQL 17 Documentation.* [https://www.postgresql.org/docs/17/](https://www.postgresql.org/docs/17/)

PostgreSQL Global Development Group. *Hot Standby.* PostgreSQL 17 Documentation. [https://www.postgresql.org/docs/17/hot-standby.html](https://www.postgresql.org/docs/17/hot-standby.html)

MongoDB, Inc. *MongoDB Manual,* release notes for 7.0. [https://www.mongodb.com/docs/manual/release-notes/7.0/](https://www.mongodb.com/docs/manual/release-notes/7.0/)

## AI-use declaration

I used Cursor, with Grok, to draft SQL, scripts, the Docker setup, and parts of the write-ups. The figures in this summary come from the saved output of the local PostgreSQL and MongoDB runs. Where a script changed the database, the saved transcript is the source for the number quoted here.
