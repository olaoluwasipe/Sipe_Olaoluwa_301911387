-- Place one ShopFlow order in a single transaction.
-- orders.total is set from the order items before COMMIT.

\set ON_ERROR_STOP on
\timing on

\echo '=== Stock and orders before the transaction ==='
SELECT id, name, stock
FROM products
WHERE name = 'Notebook';

SELECT COUNT(*) AS orders, MAX(id) AS max_order_id
FROM orders;

BEGIN;

INSERT INTO orders (customer_id, status, total)
SELECT id, 'confirmed', 0
FROM customers
WHERE email = 'alice@example.com'
RETURNING id \gset order_

INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT :order_id, p.id, 2, p.price
FROM products p
WHERE p.name = 'Notebook';

UPDATE products
SET stock = stock - 2
WHERE name = 'Notebook';

INSERT INTO inventory_logs (product_id, "change", reason)
SELECT id, -2, 'Portfolio 3 order fulfilment'
FROM products
WHERE name = 'Notebook';

UPDATE orders AS o
SET total = (
    SELECT SUM(quantity * price)
    FROM order_items
    WHERE order_id = o.id
)
WHERE o.id = :order_id;

\echo '=== Order total and stock before COMMIT ==='
SELECT
    o.id,
    o.status,
    o.total AS recorded_total,
    SUM(oi.quantity * oi.price) AS calculated_total
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.id
WHERE o.id = :order_id
GROUP BY o.id, o.status, o.total;

SELECT name, stock
FROM products
WHERE name = 'Notebook';

COMMIT;

\echo '=== Stock and the saved order after COMMIT ==='
SELECT id, name, stock
FROM products
WHERE name = 'Notebook';

SELECT
    o.id,
    c.name AS customer,
    o.status,
    o.total
FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id
WHERE o.id = :order_id;
