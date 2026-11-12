# Project Plan

ShopFlow uses one case study for every portfolio. This file is the checklist. Each portfolio README repeats the list for that folder. When a task is finished, tick it here and in that README.

A task stays open until the commands have been run and the output is saved. Writing the script is not the same as finishing the task.

## Status

Checked on 12 November 2026.

| Portfolio | Marks | Status |
|---|---:|---|
| 1. Database design and modelling | 7 | Done. Schema, seed, rendered ER diagram, write-ups, and run steps are in the folder. |
| 2. Query processing and optimisation | 7 | Done. Six queries, three index experiments, saved plans, and saved result rows are in the folder. |
| 3. Transactions and concurrency | 7 | Done. A committed order, a rolled-back order, a lost update, and a row-lock run are saved. |
| 4. NoSQL and advanced data models | 7 | Done. MongoDB holds five customer history documents. Query output is saved. |
| 5. Distributed and cloud databases | 6 | Not started. The primary and replica idea is named in the case study only. |
| Final documentation | 6 | Not started. The case study and this plan exist. The LMS summary does not. |

## Working order

1. Portfolios 1 to 4 are closed. Push the local commits that are not on origin yet.
2. Portfolio 5: primary and read replica for ShopFlow.
3. The 2–3 page LMS summary, reflection, references, and AI-use declaration.

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
- [x] Screenshot files renamed with the `Sipe_Olaoluwa_301911387_` prefix and no spaces. Each name says what the image shows.

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
- [x] Experiment 2 in `Experiment2.md`. Saved plans: `Experiment2_before.txt` (6.722 ms) and `Experiment2_after.txt` (0.879 ms). The earlier capture of the same plan shapes was 2.565 ms then 0.895 ms. The 95.582 ms ordered index scan is left out of the comparison table.
- [x] `indexes.sql` with the three `CREATE INDEX` statements and `ANALYZE`.
- [x] Experiment 3, Query 2. `idx_order_items_product_id` did not change the sequential scans. Before file 92.564 ms, after file 31.001 ms, same access method and the same scan buffer counts. The screenshot baseline was 58.062 ms.
- [x] Result rows for all six queries in `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query_results.txt`.
- [x] Portfolio 2 README run order: schema, seed, benchmark script, timestamp script, indexes, then the six queries.

## Portfolio 3 — Transactions and concurrency (7 marks)

**Brief:** a commit, a rollback, an isolation or concurrency example, and saved output.

Use the same ShopFlow tables. `orders.total` must be updated in the same transaction as the order items, as the normalisation note already says.

**Done**

- [x] `place_order.sql` commits one Notebook order. Stock goes from 150 to 148, and `orders.total` is 2400.00, matching the line. Output is saved.
- [x] `rollback_order.sql` fails `products_stock_check` on an order for 100,000 notebooks, then `ROLLBACK`. Stock stays 148 and the order count stays 20006.
- [x] Two sessions on Pen Pack under read committed. Both read 100. Final stock is 97, so the reduction of 2 is lost. Session B waited 2026 ms. Both transcripts are saved.
- [x] Two sessions on HDMI Cable with `SELECT ... FOR UPDATE`. Session B waited 2615 ms, read 73, and the final stock is 70, which is 75 - 2 - 3.
- [x] `notes.md` states the isolation level, the lost update, and what the row lock changed.
- [x] README: how to open the two sessions and which scripts to run.

## Portfolio 4 — NoSQL and advanced data models (7 marks)

**Brief:** a NoSQL model of the same case study, a working example, saved output, and why that model fits.

MongoDB holds customer order history only. It does not replace PostgreSQL and it does not copy every table.

**Done**

- [x] MongoDB 7 service added to `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml`, port 27017.
- [x] `model.md`. One customer document with orders and line items embedded. Copied fields and relational fields are listed. History reads fit a document. Stock checks and payments stay in PostgreSQL because they need transactions.
- [x] `seed.js` with the five sample customers, orders 1 to 5, and Alice's order 20006.
- [x] `queries.js`: Alice's history, confirmed orders, and the sum of Alice's stored order totals.
- [x] Query output saved. Confirmed orders are 1, 4, and 20006. Alice's total is 34400.
- [x] README: how to start MongoDB and run the queries.

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
