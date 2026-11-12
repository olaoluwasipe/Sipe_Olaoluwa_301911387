
-- QUERY 1: Customer order history
SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    o.id AS order_id,
    o.status,
    o.total,
    o.created_at
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE c.id = 500
ORDER BY o.created_at DESC;


-- QUERY 2: Top 10 best-selling products
SELECT
    p.id AS product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.price) AS sales_value
FROM products p
JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY units_sold DESC
LIMIT 10;


-- QUERY 3: Monthly revenue from successful payments
SELECT
    DATE_TRUNC('month', o.created_at) AS revenue_month,
    COUNT(p.id) AS successful_payment_count,
    SUM(p.amount) AS monthly_revenue
FROM orders o
JOIN payments p ON p.order_id = o.id
WHERE p.status = 'successful'
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY revenue_month;


-- QUERY 4: Products with low stock
-- Business threshold: 15 units or fewer
SELECT
    p.id,
    p.name,
    c.name AS category,
    p.stock
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE p.stock <= 15
ORDER BY p.stock ASC, p.name;


-- QUERY 5: Top 10 customers by completed order value
SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    COUNT(o.id) AS completed_orders,
    SUM(o.total) AS total_spending
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.status IN ('confirmed', 'shipped', 'delivered')
GROUP BY c.id, c.name
ORDER BY total_spending DESC
LIMIT 10;


-- QUERY 6: Payment status analysis
SELECT
    status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount
FROM payments
GROUP BY status
ORDER BY payment_count DESC;
