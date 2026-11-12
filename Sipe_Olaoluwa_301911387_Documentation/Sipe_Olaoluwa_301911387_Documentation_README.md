# Final documentation and evidence

The LMS submission is a 2–3 page summary written after the five portfolios have saved evidence.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** summary of all five activities, selected organisation, GitHub link, evidence, individual reflection, references, and an AI-use declaration. 6 marks.

One file holds the whole submission: `Sipe_Olaoluwa_301911387_Documentation_summary.md`. Reflection, references, the repository link, and the AI-use declaration are sections of that file. A second essay would push the LMS piece past 2–3 pages. Portfolio evidence stays in the portfolio folders. The summary names the files. It does not paste the screenshots or the query output.

On 12 November 2026, `main` was even with `origin/main` and the working tree was clean. Portfolio 5 is already on the remote. The old note that `main` was 6 commits ahead is out of date.

**Done**

- [x] `Sipe_Olaoluwa_301911387_Documentation_summary.md`, about 960 words, covering ShopFlow and all five portfolios.
- [x] GitHub link `https://github.com/olaoluwasipe/Sipe_Olaoluwa_301911387`. On 12 November 2026 the page opened without a login and showed the portfolio title, so the repository is public.
- [x] The summary points at the saved screenshots and output in the portfolio folders.
- [x] Reflection in the summary: design choices, the bitmap sort, the unused Query 2 index, the Pen Pack lost update, the replica lag on Query 3, and what the write-ups say because of those runs.
- [x] References for PostgreSQL 17, hot standby, and MongoDB 7.
- [x] AI-use declaration: Cursor with Grok drafted scripts and write-ups. The figures are taken from the saved database runs.
- [x] LMS file listed below.

## Order of work

1. Draft the summary from the saved files. Use the numbers already printed in those files. Do not re-run the scripts in order to get new figures.
2. Read the draft once for length. Five portfolio paragraphs, three short reflection paragraphs, a short reference list, and one AI-use paragraph should land in 2–3 pages. Cut a portfolio paragraph before cutting the reflection.
3. Put the repository link in the opening paragraph: `https://github.com/olaoluwasipe/Sipe_Olaoluwa_301911387`.
4. Open that link in a private window. If GitHub asks for a login, the repository is private. Add the assessor, then open the link again while logged out.
5. Tick the checklist in this README and in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Set the final-documentation row in both status tables to done. Replace the repository task that still says `main` was 6 commits ahead.
6. Commit the summary on its own, then push `main`.

## What the summary says

**Opening.** ShopFlow is one shop used for every portfolio. PostgreSQL holds customers, products, orders, payments, and stock. MongoDB holds customer order history only. The primary is port 5433 and the read replica is port 5435. Then the GitHub link.

**Portfolio 1.** Seven tables, keys, and the normalisation choice that `orders.total` is stored and must be maintained inside the order transaction. Point at `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.png`, `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_Normalization.md`, and `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_seed_row_counts.png`.

**Portfolio 2.** Six queries on the benchmark load. Experiment 1 and Experiment 2 got faster with indexes. Experiment 3, the product index on Query 2, did not change the sequential scans. Point at `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_query_results.txt`, `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment2.md`, and `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_Experiment3.md`.

**Portfolio 3.** One committed Notebook order, one rolled-back order that failed `products_stock_check`, a lost update on Pen Pack, and the same pattern on HDMI Cable with `SELECT ... FOR UPDATE`. Point at `Sipe_Olaoluwa_301911387_Portfolio3_Transactions_notes.md`.

**Portfolio 4.** One customer document with orders embedded. Stock and payments stay in PostgreSQL. Alice's stored order totals are 34400. Confirmed orders are 1, 4, and 20006. Point at `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_model.md` and `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_query_output.txt`.

**Portfolio 5.** Asynchronous physical replica. Product lists and Query 3 read from port 5435. Orders, stock, and payments write to port 5433. With replay paused, November 2026 on the replica stayed at 458 payments and 159780710.00 while the primary showed 459 and 159780711.00. An insert on the replica was rejected. Point at `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_design.md` and `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_replica_read_output.txt`.

**Reflection.** Three beats, in this order.

- Design choices: PostgreSQL for anything that needs a transaction, MongoDB for a history read, and a read replica only for product lists and sales reports. The stock check stays on the primary.
- What failed: the bitmap scan in Experiment 1 still sorted; the Query 2 index did not replace the sequential scans; read committed lost the Pen Pack update; the replica's Query 3 missed one committed payment until replay resumed.
- What changed: Experiment 1 records that the sort remained; Experiment 3 reports the unchanged access method; Portfolio 3 adds `FOR UPDATE` on HDMI Cable; Portfolio 5 states that the stock check reads the primary.

**References.** PostgreSQL 17 for the server, the write-ahead log, and hot standby. MongoDB 7 for the document model. Any other source only if the summary actually uses it.

**AI-use.** Name the tool, say what it drafted, and say that the figures in the summary were taken from the saved runs rather than from the draft.

## LMS file

Upload this file:

- `Sipe_Olaoluwa_301911387_Documentation_summary.md`

The GitHub link inside it is `https://github.com/olaoluwasipe/Sipe_Olaoluwa_301911387`. Screenshots and command output stay in the portfolio folders. The summary names them.
