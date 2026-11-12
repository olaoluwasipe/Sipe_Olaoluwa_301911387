# ShopFlow Case Study

## 1. Background

ShopFlow is a sample online shop. Customers can browse products, place orders, make payments, and receive updates about their orders. The shop also needs to keep track of stock.

The case study is small enough to build and test on a local computer, but it includes common database tasks such as storing related records, finding sales data, handling stock changes, and reading customer order history.

## 2. Main problem

The shop needs reliable records for customers, products, orders, payments, and stock. It must avoid problems such as orders being saved without their items or two orders using the same remaining stock.

The database should also make it possible to answer questions about sales and stock without writing a new query for every report.

## 3. Planned database approach

PostgreSQL will be the main database. It will store the records that need clear relationships and reliable transactions.

The planned tables are:

- `customers` — customer details.
- `categories` — product groups.
- `products` — product details and current stock.
- `orders` — each customer's order.
- `order_items` — the products and quantities in an order.
- `payments` — payment records for orders.
- `inventory_logs` — records of stock changes.

MongoDB will be used for a focused customer order-history example. It will not replace the main PostgreSQL database or hold a second copy of every table.

The distributed database portfolio uses a PostgreSQL primary and one read replica. The replica is a second local PostgreSQL container. Orders, stock changes, and payments are written to the primary. Product lists and sales reports are read from the replica. The design note and run steps are in the Portfolio 5 folder.

## 4. Main tasks

The project will use the same ShopFlow case study for all five portfolios:

1. Design the relational model and explain the table relationships and normalisation.
2. Write useful SQL queries and test query plans before and after suitable indexes.
3. Use transactions to process orders and test what happens when two sessions update stock.
4. Store and query customer order history in MongoDB.
5. Explain how a primary database and read replica can support read traffic and recovery.

## 5. Scope limits

This is a database assignment, not a full online shop application. It will not include a frontend, mobile app, payment gateway, user login system, or a large microservice setup.

The project will focus on the database work required by the course brief. Any results, screenshots, and performance claims will be added after they have been tested.
