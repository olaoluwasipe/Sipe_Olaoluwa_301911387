# Project Plan

ShopFlow uses one case study for every portfolio. This file is the checklist. Each portfolio README repeats the list for that folder. When a task is finished, tick it here and in that README.

A task stays open until the commands have been run and the output is saved. Writing the script is not the same as finishing the task.

## Status

Checked on 12 November 2026.

| Portfolio | Marks | Status |
|---|---:|---|
| 1. Database design and modelling | 7 | Done. Schema, seed, rendered ER diagram, write-ups, and run steps are in the folder. |
| 2. Query processing and optimisation | 7 | In progress. Six queries and one index experiment are done. A second experiment and saved query results are still open. |
| 3. Transactions and concurrency | 7 | Not started. |
| 4. NoSQL and advanced data models | 7 | Not started. |
| 5. Distributed and cloud databases | 6 | Not started. The primary and replica idea is named in the case study only. |
| Final documentation | 6 | Not started. The case study and this plan exist. The LMS summary does not. |

## Working order

1. Portfolio 1 is closed. Close the open Portfolio 2 tasks, including the push of local commits.
2. Finish the second query experiment in Portfolio 2.
3. Portfolio 3: commit, rollback, and the two-session stock test.
4. Portfolio 4: MongoDB customer order history.
5. Portfolio 5: primary and read replica for ShopFlow.
6. The 2–3 page LMS summary, reflection, references, and AI-use declaration.

## Working approach

Each portfolio follows the same steps:

1. Read the portfolio requirements and list the evidence needed.
2. Build the smallest useful example that meets the requirements.
3. Run the SQL or database commands.
4. Check the results and fix any issues.
5. Save evidence and explain what the results mean.
6. Update the portfolio README.
7. Commit the finished piece of work.

## Repository tasks

These sit outside a single portfolio and affect the whole submission.

- [ ] Push the local commits that are not on origin yet. On 12 November 2026, `main` was 6 commits ahead of origin.
- [ ] Keep committing each finished piece as it is completed, so the history is spread across the work rather than one upload at the deadline.
- [ ] If the GitHub repository stays private, give the assessor access before the LMS submission.
- [ ] Rename screenshot files so the names have no spaces. Use the `Sipe_Olaoluwa_301911387_` prefix.

## Portfolio 1 — Database design and modelling (7 marks)

**Brief:** case study, ER diagram, relational schema, keys, constraints, and a normalisation explanation.

**Done**

- [x] Case study in `Sipe_Olaoluwa_301911387_CASE_STUDY.md`: shop, data, and operations.
- [x] `schema.sql`: seven tables, primary keys, foreign keys, checks, and a unique `(order_id, product_id)` constraint.
- [x] `orders.created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` is in `schema.sql` and on the ER diagram. The running database already had this definition. The Portfolio 2 timestamp script uses `ADD COLUMN IF NOT EXISTS`, then spreads the timestamps and inserts benchmark payments.
- [x] `seed.sql` loaded. The 11 November screenshot shows 5 customers, 5 categories, 9 products, 5 orders, 9 order items, 5 payments, and 9 inventory logs.
- [x] Mermaid ER diagram in `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.mmd`.
- [x] Rendered ER diagram in `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.png`.
- [x] Relationship write-up.
- [x] Normalisation write-up, including the note that `orders.total` is a stored aggregate and Portfolio 3 must update it in the same transaction as the order items.
- [x] Docker Compose file for PostgreSQL 17 on port 5433.
- [x] Portfolio 1 README run steps: start Compose, apply `schema.sql`, apply `seed.sql`, and say what the 11 November screenshots show.

## Portfolio 2 — Query processing and optimisation (7 marks)

**Brief:** SQL queries, query results, execution plans, indexing evidence, and a short performance analysis.

**Assumptions already in the README**

- Query 4 treats 15 units or fewer as low stock.
- Query 5 treats confirmed, shipped, and delivered as completed.
- Query 3 sums successful payments by order month. It is not a full accounting model.
- Generated timestamps and benchmark payments are synthetic.

**Done**

- [x] Six business queries in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_business_queries.sql`.
- [x] Benchmark load: 1,000 extra customers, 20 categories, 2,000 products, 20,000 orders, and three lines per generated order.
- [x] Timestamp and benchmark payment script.
- [x] Experiment 1, customer 500 order history sorted by `orders.id`. Baseline sequential scan 4.090 ms, saved in `baseline.md`. After `idx_orders_customer_id_id_desc`, bitmap heap scan 2.273 ms. The sort stayed because a bitmap scan does not keep index order. Plan screenshots are in the folder.

**Still to do**

- [ ] Move the `(customer_id, created_at DESC)` index write-up into `Experiment2.md`. That file currently repeats Experiment 1. The 0.895 ms result is an extra section at the bottom of `Experiment1.md`.
- [ ] Save the before and after `EXPLAIN (ANALYZE, BUFFERS)` text for the `created_at` index next to the screenshots.
- [ ] Leave the `enable_bitmapscan = off` run out of the improvement table. That plan used an ordered index scan and took 95.582 ms, which is slower than the bitmap plan.
- [ ] Add `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_indexes.sql` with the `CREATE INDEX` statements and `ANALYZE`. The statements currently live only inside the experiment notes.
- [ ] Run a second optimisation on Query 2, top 10 products. The 08:24 screenshot already has the baseline: sequential scans of about 60,009 order items and 2,009 products, hash aggregate, 58.062 ms. Test an index on `order_items (product_id)`. Save the before and after plans, and describe the access method and buffer counts as well as the time.
- [ ] Save the result rows for all six queries, not only the plans.
- [ ] Replace the placeholder part of the README with the run order: schema, seed, benchmark script, timestamp script, indexes, then the six queries. Keep the assumptions.

## Portfolio 3 — Transactions and concurrency (7 marks)

**Brief:** a commit, a rollback, an isolation or concurrency example, and saved output.

Use the same ShopFlow tables. `orders.total` must be updated in the same transaction as the order items, as the normalisation note already says.

**Still to do**

- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_place_order.sql`. In one transaction: insert the order, insert the items, reduce `products.stock`, insert `inventory_logs`, set `orders.total` from the items, then `COMMIT`. Save stock before and after.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_rollback_order.sql`. Start the same order, fail it when stock is too low, and `ROLLBACK`. Save output that shows the stock and the order list are unchanged.
- [ ] Two `psql` sessions on one product, under the default isolation level. Both read the same stock and both write a reduction, so one update is lost. Save both session transcripts.
- [ ] Repeat the two-session test with `SELECT ... FOR UPDATE` on the product row. One session waits. The final stock matches both reductions. Save both transcripts.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md`. State the isolation level, what the lost update was, and what the row lock changed.
- [ ] README: how to open the two sessions and which scripts to run.

## Portfolio 4 — NoSQL and advanced data models (7 marks)

**Brief:** a NoSQL model of the same case study, a working example, saved output, and why that model fits.

MongoDB holds customer order history only. It does not replace PostgreSQL and it does not copy every table.

**Still to do**

- [ ] Add a MongoDB service to `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml`.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_model.md`. One customer document with orders and line items embedded. Say which ShopFlow fields are copied and which stay relational.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_seed.js` with a few customer documents taken from the sample shop data.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_queries.js`: one customer's history, orders filtered by status, and total spend for a customer.
- [ ] Save the query output.
- [ ] Short suitability note in the model file: history reads fit a document; stock checks and payments stay in PostgreSQL because they need transactions.
- [ ] README: how to start MongoDB and run the queries.

## Portfolio 5 — Distributed and cloud databases (6 marks)

**Brief:** replication, sharding, availability, consistency, or a deployment, using the same case study. A discussion or a setup both meet the brief.

Keep this to a ShopFlow primary and one read replica.

**Still to do**

- [ ] `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_design.md`.
- [ ] Data flow: orders, stock changes, and payments write to the primary. Product lists and sales reports read from the replica.
- [ ] State that the stock check before an order reads the primary. A replica can be behind the latest sale.
- [ ] State what replica lag does to Query 3, monthly revenue.
- [ ] Availability: what a primary failure means for new orders, and what the replica can still serve.
- [ ] Either add a second PostgreSQL container and show a replica read, or write in the design note that this portfolio is a design discussion and name what was not run.
- [ ] README: how the design maps onto ShopFlow, and how to run the replica if one was built.

## Final documentation (6 marks)

Write this after the five portfolios have saved evidence. The LMS submission is 2–3 pages.

**Still to do**

- [ ] `Sipe_Olaoluwa_301911387_Documentation_summary.md`, 2–3 pages, covering all five portfolios and the ShopFlow case study.
- [ ] GitHub repository link, and a check that the link opens for the assessor.
- [ ] Pointers to the screenshots and output already saved in the portfolio folders.
- [ ] Individual reflection: design choices, what failed during testing, and what changed because of that.
- [ ] References for PostgreSQL, MongoDB, and any other external material used.
- [ ] AI-use declaration: the tool, what it was used for, and how the output was checked against a real database run.
- [ ] README in the documentation folder that points at the summary and lists the files submitted on the LMS.

## Commit approach

Commits are made when a useful piece of work is ready. Messages say what changed, for example:

- `docs: add ShopFlow case study`
- `feat: create relational schema`
- `test: check order rollback`

The history shows the real order of the work. Commits are not backdated and are not created just to reach a target number.
