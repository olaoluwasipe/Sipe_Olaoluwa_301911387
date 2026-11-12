# Portfolio 4: NoSQL and Advanced Data Models

MongoDB customer order history for the same ShopFlow shop. Stock and payments stay in PostgreSQL.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** a NoSQL model of the same case study, a working example, saved output, and why that model fits. 7 marks.

**Done**

- [x] MongoDB 7 service `shopflow-mongo` in `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml`, on port 27017.
- [x] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_model.md`. One customer document with orders and line items embedded. It lists the copied fields and the fields that stay relational.
- [x] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_seed.js`. Five customer documents from the sample shop: orders 1 to 5, plus Alice Johnson's Notebook order 20006. Benchmark orders are not copied.
- [x] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_queries.js`: Alice's history, orders with status `confirmed`, and the sum of Alice's stored order totals.
- [x] Query output in `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_query_output.txt`. Alice's two orders total 34400. The confirmed orders are 1, 4, and 20006.
- [x] Suitability note in the model file: history reads fit a document; stock checks and payments stay in PostgreSQL because they need transactions.
- [x] Run steps below.

## How to run

PostgreSQL stays as it is. This service only adds MongoDB.

From `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign`:

```bash
docker compose -f Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml up -d
```

MongoDB listens on `localhost:27017`. The database name is `shopflow`. There is no MongoDB user; this container is for the local machine only.

From this folder:

```bash
docker cp Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_seed.js shopflow-mongo:/tmp/shopflow_seed.js
docker cp Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_queries.js shopflow-mongo:/tmp/shopflow_queries.js

docker exec shopflow-mongo mongosh shopflow --quiet --file /tmp/shopflow_seed.js
docker exec shopflow-mongo mongosh shopflow --quiet --file /tmp/shopflow_queries.js
```

The seed replaces the documents in `customer_order_history`, so it is safe to run again.

`Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_query_output.txt` is the saved query output:

- Alice Johnson's document has order 1 (Wireless Mouse and Mechanical Keyboard, 32000) and order 20006 (two Notebooks, 2400).
- The confirmed-status query returns order 1, David's order 4 at 11000, and order 20006.
- Alice's stored order totals sum to 34400 across 2 orders. That sum is the order totals, not the payment records, which stay in PostgreSQL.
