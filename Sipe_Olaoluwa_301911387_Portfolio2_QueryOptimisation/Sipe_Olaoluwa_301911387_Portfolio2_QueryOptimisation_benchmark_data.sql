
BEGIN;

-- Generate 1,000 additional customers
INSERT INTO customers (name, email)
SELECT
    'Benchmark Customer ' || LPAD(g::TEXT, 4, '0'),
    'benchmark.customer.' || LPAD(g::TEXT, 4, '0') || '@shopflow.test'
FROM generate_series(1, 1000) AS g;

-- Generate 20 additional categories
INSERT INTO categories (name)
SELECT
    'Benchmark Category ' || LPAD(g::TEXT, 2, '0')
FROM generate_series(1, 20) AS g;

-- Generate 2,000 additional products
INSERT INTO products (category_id, name, price, stock)
SELECT
    (
        SELECT id
        FROM categories
        ORDER BY id
        OFFSET ((g - 1) % (SELECT COUNT(*) FROM categories))
        LIMIT 1
    ),
    'Benchmark Product ' || LPAD(g::TEXT, 4, '0'),
    (1000 + ((g * 137) % 99000))::NUMERIC(12, 2),
    (5 + ((g * 17) % 200))::INTEGER
FROM generate_series(1, 2000) AS g;

-- Generate 20,000 additional orders
INSERT INTO orders (customer_id, status, total)
SELECT
    (
        SELECT id
        FROM customers
        ORDER BY id
        OFFSET ((g - 1) % (SELECT COUNT(*) FROM customers))
        LIMIT 1
    ),
    CASE
        WHEN g % 5 = 0 THEN 'pending'
        WHEN g % 5 = 1 THEN 'confirmed'
        WHEN g % 5 = 2 THEN 'processing'
        WHEN g % 5 = 3 THEN 'shipped'
        ELSE 'delivered'
    END,
    0
FROM generate_series(1, 20000) AS g;

-- Add three product lines to each generated order.
-- The original five sample orders are left untouched.
INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT
    o.id,
    p.id,
    1 + ((o.id + line.line_no) % 4),
    p.price
FROM orders o
CROSS JOIN generate_series(1, 3) AS line(line_no)
JOIN LATERAL (
    SELECT id, price
    FROM products
    ORDER BY id
    OFFSET (
        (o.id * 7 + line.line_no * 13)
        % (SELECT COUNT(*) FROM products)
    )
    LIMIT 1
) p ON TRUE
WHERE o.id > 5;

-- Calculate totals from the generated order items.
UPDATE orders o
SET total = totals.calculated_total
FROM (
    SELECT
        order_id,
        SUM(quantity * price) AS calculated_total
    FROM order_items
    WHERE order_id > 5
    GROUP BY order_id
) totals
WHERE o.id = totals.order_id;

COMMIT;

-- Refresh PostgreSQL statistics for query planning.
ANALYZE;
