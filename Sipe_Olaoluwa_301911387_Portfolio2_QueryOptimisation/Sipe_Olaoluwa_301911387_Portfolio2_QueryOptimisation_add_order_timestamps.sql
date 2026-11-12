
BEGIN;

-- Add a timestamp to each order.
ALTER TABLE orders
ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Spread synthetic order dates across the previous 365 days.
-- This makes monthly reporting possible for benchmark purposes.
UPDATE orders
SET created_at =
    NOW()
    - ((id % 365)::INTEGER * INTERVAL '1 day')
    - ((id % 24)::INTEGER * INTERVAL '1 hour');

-- Create benchmark payment records for generated orders.
-- The original five sample payment records are preserved.
INSERT INTO payments (order_id, amount, status)
SELECT
    o.id,
    o.total,
    CASE
        WHEN o.status = 'pending' THEN 'pending'
        ELSE 'successful'
    END
FROM orders o
WHERE o.id > 5
  AND NOT EXISTS (
      SELECT 1
      FROM payments p
      WHERE p.order_id = o.id
  );

COMMIT;

ANALYZE orders;
ANALYZE payments;
