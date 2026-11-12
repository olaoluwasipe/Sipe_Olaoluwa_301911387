# Portfolio 3: Transactions and Concurrency

Order placement, a failed order, and two sessions updating the same product stock.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** a commit, a rollback, an isolation or concurrency example, and saved output. 7 marks.

Use the ShopFlow tables. `orders.total` is updated in the same transaction as the order items.

**Still to do**

- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql`. In one transaction: insert the order, insert the items, reduce `products.stock`, insert `inventory_logs`, set `orders.total` from the items, then `COMMIT`. Save stock before and after.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql`. Fail the order when stock is too low, then `ROLLBACK`. Save output that shows the stock and the order list are unchanged.
- [ ] Two `psql` sessions on one product, under the default isolation level. Both read the same stock and both write a reduction, so one update is lost. Save both session transcripts.
- [ ] Repeat the two-session test with `SELECT ... FOR UPDATE` on the product row. One session waits. The final stock matches both reductions. Save both transcripts.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md`. State the isolation level, what the lost update was, and what the row lock changed.
- [ ] Write the two-session run steps in this README.

## How to run

Run steps will be written here when the scripts have been tested.
