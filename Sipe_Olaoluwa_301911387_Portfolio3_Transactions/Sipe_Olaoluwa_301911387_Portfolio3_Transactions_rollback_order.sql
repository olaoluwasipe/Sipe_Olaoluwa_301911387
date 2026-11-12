-- Start an order that asks for more Notebook stock than the shop has.
-- The stock check fails, ROLLBACK removes the order, and the saved rows stay as they were.
-- ON_ERROR_STOP is off so psql continues to the ROLLBACK after the constraint error.

\set ON_ERROR_STOP off
\timing on

\echo '=== Before the failed order ==='
SELECT name, stock
FROM products
WHERE name = 'Notebook';

SELECT COUNT(*) AS orders, MAX(id) AS max_order_id
FROM orders;

SELECT COUNT(*) AS notebook_logs
FROM inventory_logs AS l
JOIN products AS p ON p.id = l.product_id
WHERE p.name = 'Notebook';

BEGIN;

INSERT INTO orders (customer_id, status, total)
SELECT id, 'confirmed', 0
FROM customers
WHERE email = 'alice@example.com'
RETURNING id \gset order_

INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT :order_id, p.id, 100000, p.price
FROM products p
WHERE p.name = 'Notebook';

UPDATE products
SET stock = stock - 100000
WHERE name = 'Notebook';

ROLLBACK;

\echo '=== After ROLLBACK ==='
SELECT name, stock
FROM products
WHERE name = 'Notebook';

SELECT COUNT(*) AS orders, MAX(id) AS max_order_id
FROM orders;

SELECT COUNT(*) AS notebook_logs
FROM inventory_logs AS l
JOIN products AS p ON p.id = l.product_id
WHERE p.name = 'Notebook';
