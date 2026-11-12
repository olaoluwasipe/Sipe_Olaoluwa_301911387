-- Portfolio 2 indexes.
-- CREATE INDEX IF NOT EXISTS keeps this script safe when an index is already present.

CREATE INDEX IF NOT EXISTS idx_orders_customer_id_id_desc
    ON orders (customer_id, id DESC);

CREATE INDEX IF NOT EXISTS idx_orders_customer_created_at
    ON orders (customer_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items (product_id);

ANALYZE orders;
ANALYZE order_items;
ANALYZE products;
