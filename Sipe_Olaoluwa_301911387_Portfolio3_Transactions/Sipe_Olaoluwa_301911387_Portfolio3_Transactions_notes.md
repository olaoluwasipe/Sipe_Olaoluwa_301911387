# ShopFlow transactions and concurrency

The tests used the running ShopFlow database. `SHOW transaction_isolation` in both sessions returned `read committed`, which is PostgreSQL's default.

## Committed order

`Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql` places one order for Alice Johnson in a single transaction.

Notebook stock was 150 before the transaction. The transaction inserted order 20006, inserted a line for 2 notebooks at 1200.00, reduced stock to 148, wrote an inventory log of -2, and set `orders.total` from `SUM(quantity * price)`. The recorded total and the calculated total were both 2400.00. After `COMMIT`, the stock was still 148 and the order was still there.

The saved output is `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order_output.txt`.

## Rolled-back order

`Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql` starts another order for 100,000 notebooks. The stock update tries to store -99852 and fails `products_stock_check`, which requires `stock >= 0`. The script then runs `ROLLBACK`.

Before and after that run, Notebook stock was 148, the order count was 20006, the highest order id was 20006, and Notebook had 2 inventory logs. The failed order is not in the order list.

The saved output is `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order_output.txt`.

## Lost update

Pen Pack started at 100. Two sessions both read 100, then each wrote its own reduced value.

| Session | Read | Wrote | What the statement did |
|---|---:|---:|---|
| A | 100 | 98 | `stock = 100 - 2`, then `COMMIT` |
| B | 100 | 97 | `stock = 100 - 3` |

Session B's `UPDATE` waited 2026 ms because Session A held the row lock. When A committed, B wrote 97 over 98. The final stock was 97.

Both reductions would have left 95. The write of 98 was lost because B stored the number it had calculated from the earlier read, not `stock = stock - 3`. Under read committed, a plain `SELECT` does not lock the row, so both sessions can read the same stock.

Transcripts:

- `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_lost_update_session_a.txt`
- `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_lost_update_session_b.txt`

## Row lock

HDMI Cable started at 75. The same two reductions were used, with `SELECT ... FOR UPDATE`.

Session A locked the row, read 75, and wrote 73. Session B's `SELECT ... FOR UPDATE` waited 2615 ms. After A committed, B's select returned 73, and B wrote 70. The final stock was 70, which is 75 - 2 - 3.

The lock made B read the stock that A had already changed. B's reduction was applied to that value, so both reductions were kept.

Transcripts:

- `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_row_lock_session_a.txt`
- `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_row_lock_session_b.txt`

## What changed

Read committed does not stop a lost update when each session reads the stock and later writes a calculated number. `SELECT ... FOR UPDATE` takes the row lock at read time. The second session waits, sees the committed stock, and applies its own reduction to that stock.
