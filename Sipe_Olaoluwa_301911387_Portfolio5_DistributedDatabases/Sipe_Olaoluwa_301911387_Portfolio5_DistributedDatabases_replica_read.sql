-- Reads for the ShopFlow standby. Run this against port 5435.
-- Product lists and Query 3 (monthly revenue) are replica reads.
-- Stock checks and new orders stay on the primary.

SELECT
    pg_is_in_recovery() AS in_recovery,
    pg_is_wal_replay_paused() AS replay_paused,
    pg_last_wal_replay_lsn() AS replay_lsn;

SELECT status, sender_host, sender_port, slot_name
FROM pg_stat_wal_receiver;

SELECT COUNT(*) AS product_count
FROM products;

SELECT id, name, price, stock
FROM products
ORDER BY id
LIMIT 10;

-- Query 3: monthly revenue from successful payments.
SELECT
    DATE_TRUNC('month', o.created_at) AS revenue_month,
    COUNT(p.id) AS successful_payment_count,
    SUM(p.amount) AS monthly_revenue
FROM orders o
JOIN payments p ON p.order_id = o.id
WHERE p.status = 'successful'
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY revenue_month;
