# Portfolio 3: Transactions and Concurrency

Order placement, a failed order, and two sessions updating the same product stock.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** a commit, a rollback, an isolation or concurrency example, and saved output. 7 marks.

Use the ShopFlow tables. `orders.total` is updated in the same transaction as the order items.

**Done**

- [x] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql`. One transaction inserts the order and the line, reduces Notebook stock from 150 to 148, writes an inventory log, sets `orders.total` to 2400.00 from the line, and `COMMIT`s. Output is `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order_output.txt`.
- [x] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql`. An order for 100,000 notebooks fails `products_stock_check`, then `ROLLBACK`. Stock stays 148 and the order count stays 20006. Output is `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order_output.txt`.
- [x] Two sessions on Pen Pack, read committed. Both read 100. The final stock is 97, so the reduction of 2 is lost. Session B's update waited 2026 ms. Transcripts: `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_lost_update_session_a.txt` and `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_lost_update_session_b.txt`.
- [x] The same pattern on HDMI Cable with `SELECT ... FOR UPDATE`. Session B waited 2615 ms, read 73, and the final stock is 70, which is 75 - 2 - 3. Transcripts: `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_row_lock_session_a.txt` and `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_row_lock_session_b.txt`.
- [x] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md`. Isolation level is read committed. The notes state the lost update and what the row lock changed.
- [x] Run steps below.

## How to run

Connection: host `localhost`, port `5433`, database `shopflow`, user `shopflow_user`, password `shopflow_local_only`.

The running database already contains the committed Notebook order, the Pen Pack lost update, and the HDMI Cable row-lock result. Running these scripts again places another order and reduces those products again.

From this folder:

```bash
psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql

psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql

./Sipe_Olaoluwa_301911387_Portfolio3_Transactions_run_sessions.sh lost-update
./Sipe_Olaoluwa_301911387_Portfolio3_Transactions_run_sessions.sh row-lock
```

`run_sessions.sh` opens the two `psql` sessions and interleaves the statements. The manual steps are the same ones in the saved transcripts.

Lost update, Pen Pack, one statement at a time:

1. In both sessions, `BEGIN` and `SELECT stock` for Pen Pack. Both reads must finish before either update.
2. Session A: `UPDATE` the stock to the value it read, minus 2, then `COMMIT`.
3. Session B: `UPDATE` the stock to the value it read, minus 3. This waits until A commits, then overwrites A's stock.
4. Session B: `COMMIT`. The final stock includes only B's reduction.

Row lock, HDMI Cable:

1. Session A: `BEGIN` and `SELECT stock ... FOR UPDATE`.
2. Session B: `BEGIN` and `SELECT stock ... FOR UPDATE`. B waits.
3. Session A: subtract 2 from the locked stock and `COMMIT`.
4. Session B's select returns the stock A committed. B subtracts 3 from that value and `COMMIT`.

`Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md` records the stock numbers from the saved run.
