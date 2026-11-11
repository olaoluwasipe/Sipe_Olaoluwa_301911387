# ShopFlow — Database Relationships

## 1. Overview

ShopFlow uses a relational database consisting of seven tables. The database is designed to support customer management, product categorisation, order processing, payment tracking and inventory management.

The relationships between the tables are implemented using primary keys and foreign keys to maintain referential integrity.

## 2. Relationship Analysis

| Relationship | Cardinality | Explanation |
|---|---|---|
| Customers → Orders | One-to-Many | A customer can place multiple orders, but each order belongs to one customer. |
| Categories → Products | One-to-Many | A category can contain multiple products, but each product belongs to one category. |
| Orders → Order Items | One-to-Many | An order contains one or more product lines. |
| Products → Order Items | One-to-Many | A product can appear in multiple order items across different orders. |
| Orders → Payments | One-to-Many | An order can have multiple payment records, allowing payment attempts and subsequent payment activity to be recorded. |
| Products → Inventory Logs | One-to-Many | A product can have multiple inventory records representing stock movements. |

## 3. Primary and Foreign Keys

Each table has a primary key that uniquely identifies its records.

Foreign keys connect dependent records to their parent records:

- `products.category_id` references `categories.id`.
- `orders.customer_id` references `customers.id`.
- `order_items.order_id` references `orders.id`.
- `order_items.product_id` references `products.id`.
- `payments.order_id` references `orders.id`.
- `inventory_logs.product_id` references `products.id`.

These constraints prevent dependent records from referencing non-existent parent records.

## 4. Important Design Decisions

### Order Items

The `order_items` table resolves the many-to-many relationship between orders and products.

An order can contain multiple products, and a product can appear in multiple orders. The junction table stores the quantity and historical unit price for each product line.

A unique constraint on `(order_id, product_id)` prevents the same product from appearing as multiple separate lines within one order.

### Payments

Payments are stored separately from orders because an order may have multiple payment attempts. This allows ShopFlow to preserve payment history without overwriting previous payment records.

### Inventory Logs

Inventory movements are recorded independently of the current stock quantity. This provides a historical record of stock additions and deductions.

### Referential Integrity

Foreign-key constraints maintain relationships between records. Restrictive deletion rules protect important business records, while order items are deleted when their parent order is deleted.

## 5. Conclusion

The ShopFlow database uses one-to-many relationships and foreign-key constraints to organise its business data. The design separates customers, products, orders, payments and inventory activities into independent entities while maintaining their relationships.

This structure provides a foundation for reliable order processing, data consistency and future query optimisation.