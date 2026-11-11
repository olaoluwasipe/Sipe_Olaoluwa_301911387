BEGIN;

-- 1. Categories
INSERT INTO categories (name) VALUES
('Electronics'),
('Computing Accessories'),
('Furniture'),
('Stationery'),
('Audio');

-- 2. Customers
INSERT INTO customers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Brian Smith', 'brian@example.com'),
('Chika Okafor', 'chika@example.com'),
('David Williams', 'david@example.com'),
('Esther Adeyemi', 'esther@example.com');

-- 3. Products
INSERT INTO products (category_id, name, price, stock) VALUES
((SELECT id FROM categories WHERE name = 'Computing Accessories'),
 'Wireless Mouse', 8500.00, 48),

((SELECT id FROM categories WHERE name = 'Computing Accessories'),
 'Mechanical Keyboard', 15000.00, 30),

((SELECT id FROM categories WHERE name = 'Electronics'),
 'LED Monitor', 95000.00, 12),

((SELECT id FROM categories WHERE name = 'Computing Accessories'),
 'HDMI Cable', 4500.00, 75),

((SELECT id FROM categories WHERE name = 'Furniture'),
 'Office Chair', 78000.00, 8),

((SELECT id FROM categories WHERE name = 'Furniture'),
 'Office Desk', 65000.00, 10),

((SELECT id FROM categories WHERE name = 'Stationery'),
 'Notebook', 1200.00, 150),

((SELECT id FROM categories WHERE name = 'Stationery'),
 'Pen Pack', 2500.00, 100),

((SELECT id FROM categories WHERE name = 'Audio'),
 'Wireless Headset', 22000.00, 25);

-- 4. Orders
INSERT INTO orders (customer_id, status, total) VALUES
((SELECT id FROM customers WHERE email = 'alice@example.com'),
 'confirmed', 32000.00),

((SELECT id FROM customers WHERE email = 'brian@example.com'),
 'processing', 104000.00),

((SELECT id FROM customers WHERE email = 'chika@example.com'),
 'delivered', 143000.00),

((SELECT id FROM customers WHERE email = 'david@example.com'),
 'confirmed', 11000.00),

((SELECT id FROM customers WHERE email = 'esther@example.com'),
 'pending', 22000.00);

-- 5. Order items
INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT o.id, p.id, v.quantity, v.price
FROM (VALUES
    ('alice@example.com', 'Wireless Mouse', 2, 8500.00),
    ('alice@example.com', 'Mechanical Keyboard', 1, 15000.00),
    ('brian@example.com', 'LED Monitor', 1, 95000.00),
    ('brian@example.com', 'HDMI Cable', 2, 4500.00),
    ('chika@example.com', 'Office Chair', 1, 78000.00),
    ('chika@example.com', 'Office Desk', 1, 65000.00),
    ('david@example.com', 'Notebook', 5, 1200.00),
    ('david@example.com', 'Pen Pack', 2, 2500.00),
    ('esther@example.com', 'Wireless Headset', 1, 22000.00)
) AS v(customer_email, product_name, quantity, price)
JOIN customers c ON c.email = v.customer_email
JOIN orders o ON o.customer_id = c.id
JOIN products p ON p.name = v.product_name;

-- 6. Payments
INSERT INTO payments (order_id, amount, status)
SELECT o.id, v.amount, v.status
FROM (VALUES
    ('alice@example.com', 32000.00, 'successful'),
    ('brian@example.com', 104000.00, 'successful'),
    ('chika@example.com', 143000.00, 'successful'),
    ('david@example.com', 11000.00, 'successful'),
    ('esther@example.com', 22000.00, 'pending')
) AS v(customer_email, amount, status)
JOIN customers c ON c.email = v.customer_email
JOIN orders o ON o.customer_id = c.id;

-- 7. Inventory logs
INSERT INTO inventory_logs (product_id, "change", reason)
SELECT p.id, v.change, v.reason
FROM (VALUES
    ('Wireless Mouse', -2, 'Order fulfilment'),
    ('Mechanical Keyboard', -1, 'Order fulfilment'),
    ('LED Monitor', -1, 'Order fulfilment'),
    ('HDMI Cable', -2, 'Order fulfilment'),
    ('Office Chair', -1, 'Order fulfilment'),
    ('Office Desk', -1, 'Order fulfilment'),
    ('Notebook', -5, 'Order fulfilment'),
    ('Pen Pack', -2, 'Order fulfilment'),
    ('Wireless Headset', -1, 'Order fulfilment')
) AS v(product_name, change, reason)
JOIN products p ON p.name = v.product_name;

COMMIT;