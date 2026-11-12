# Portfolio 1: Database Design and Modelling

ShopFlow relational design: customers, categories, products, orders, order items, payments, and inventory logs.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** case study, ER diagram, relational schema, keys, constraints, and a normalisation explanation. 7 marks.

**Done**

- [x] Case study in `Sipe_Olaoluwa_301911387_CASE_STUDY.md`.
- [x] `schema.sql` with primary keys, foreign keys, checks, and a unique `(order_id, product_id)` constraint.
- [x] `orders.created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` is in `schema.sql` and on the ER diagram. Portfolio 2 queries use this column. The running database already had the same definition. `Sipe_Olaoluwa_301911387_Portfolio2_QueryOptimisation_add_order_timestamps.sql` now uses `ADD COLUMN IF NOT EXISTS`, then spreads those timestamps and inserts benchmark payments.
- [x] `seed.sql` loaded. The 11 November screenshot shows 5 customers, 5 categories, 9 products, 5 orders, 9 order items, 5 payments, and 9 inventory logs.
- [x] Mermaid ER diagram in `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.mmd`.
- [x] Rendered diagram in `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.png`.
- [x] Relationship write-up.
- [x] Normalisation write-up, including `orders.total` as a stored aggregate for Portfolio 3 to maintain inside the order transaction.
- [x] Docker Compose for PostgreSQL 17 on port 5433.
- [x] Run steps below, including what the saved screenshots show.

## How to run

These steps are for an empty database. The current `shopflow` database already has this schema, this seed, and the Portfolio 2 benchmark load. Running `schema.sql` again fails because the tables exist.

From this folder:

```bash
docker compose -f Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml up -d
```

PostgreSQL 17 listens on `localhost:5433`. Database `shopflow`, user `shopflow_user`, password `shopflow_local_only` (set in the Compose file).

```bash
psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_schema.sql

psql -h localhost -p 5433 -U shopflow_user -d shopflow \
  -f Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_seed.sql
```

`schema.sql` creates the seven tables. `orders.created_at` is created here, so a fresh database already has the column Portfolio 2 needs. The five seed orders receive the time the seed runs. The Portfolio 2 timestamp script later spreads `created_at` across the previous year for monthly reporting.

## Saved evidence

`Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.png` is the rendered ER diagram. It shows the seven tables, the primary and foreign keys, and `orders.created_at`. The Mermaid source is `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_ERD.mmd`.

The screenshots below were taken on 11 November 2026, after the seed and before the Portfolio 2 benchmark. Counts on the current database are higher because that benchmark has since been loaded.

- `Screenshot 2026-11-11 at 13.47.22.png` — row counts after the seed: 5 customers, 5 categories, 9 products, 5 orders, 9 order items, 5 payments, and 9 inventory logs. Client `psql` 18.4, server PostgreSQL 17.11, port 5433.
- `Screenshot 2026-11-11 at 13.47.28.png` — `orders.total` matches `SUM(quantity * price)` for all five seed orders: Alice Johnson 32000.00, Brian Smith 104000.00, Chika Okafor 143000.00, David Williams 11000.00, Esther Adeyemi 22000.00.
- `Screenshot 2026-11-11 at 13.54.11.png` — the six foreign keys: `products.category_id`, `orders.customer_id`, `order_items.order_id`, `order_items.product_id`, `payments.order_id`, and `inventory_logs.product_id`.
