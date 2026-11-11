# ShopFlow Database Normalization

| Normal form | How ShopFlow satisfies it |
| --- | --- |
| 1NF | Atomic values and no repeating groups |
| 2NF | No partial dependencies on candidate keys |
| 3NF | Independent entities separated to reduce transitive dependencies |

## 1. What is database normalization?

Normalization is the process of structuring relational database tables to reduce unnecessary data duplication and prevent insertion, update and deletion anomalies.

For ShopFlow, we use three normal forms:

- **1NF:** Every column contains atomic values, with no repeating groups.
- **2NF:** Every non-key attribute depends on the whole candidate key, not just part of it.
- **3NF:** Non-key attributes depend on keys, the whole key, and nothing but the key.

## 2. First Normal Form (1NF)

ShopFlow satisfies 1NF because:

1. Each table has a defined primary key.
2. Each column stores a single value rather than a list of values.
3. Repeating groups are separated into related tables.
4. Each record can be uniquely identified.

For example, instead of storing multiple products in a single order record:

| order_id | customer | products |
| --- | --- | --- |
| 1 | Alice Johnson | Mouse, Keyboard |

We use a separate `order_items` table:

| id | order_id | product_id | quantity | price |
| --- | --- | --- | --- | --- |
| 1 | 1 | 1 | 2 | 8500 |
| 2 | 1 | 2 | 1 | 15000 |

This allows each product line to be stored independently and linked to its order.

**Conclusion:** ShopFlow satisfies 1NF because its attributes contain atomic values and repeating groups are represented through separate records.

## 3. Second Normal Form (2NF)

A table satisfies 2NF when it is already in 1NF and every non-key attribute depends on the whole candidate key.

Consider `order_items`.

Its business-level candidate key is the combination of:

`(order_id, product_id)`

The attributes `quantity` and `price` describe the particular product line within an order. They depend on the combination of the order and product, rather than on either attribute independently.

We also separate product information into `products`:

| products | Purpose |
| --- | --- |
| id | Identifies the product |
| category_id | References its category |
| name | Stores its name |
| price | Stores its current selling price |
| stock | Stores available stock |

This avoids repeating product details in every order item.

Our implementation also uses a surrogate primary key, `order_items.id`, and a unique constraint on `(order_id, product_id)`.

```sql
CONSTRAINT uq_order_items_product
    UNIQUE (order_id, product_id)
```

**Conclusion:** The tables are designed to avoid partial dependencies. The unique constraint also ensures that a product appears only once per order, with its quantity represented in that line.

## 4. Third Normal Form (3NF)

A table satisfies 3NF when it is in 2NF and non-key attributes do not depend transitively on other non-key attributes.

ShopFlow separates entities according to their responsibilities.

For example:

- Customer information belongs in `customers`.
- Category information belongs in `categories`.
- Product information belongs in `products`.
- Order information belongs in `orders`.
- Individual purchased products belong in `order_items`.
- Payment information belongs in `payments`.
- Inventory movement history belongs in `inventory_logs`.

Consider the relationship between products and categories.

Instead of storing the category name repeatedly in every product record, we store `category_id`:

```text
categories
-----------
id
name

products
--------
id
category_id
name
price
stock
```

The category name is retrieved through a foreign-key relationship when needed.

Similarly, customer names and email addresses are not duplicated in every order. Orders reference customers through `customer_id`.

**Conclusion:** ShopFlow separates independent entities and references them through foreign keys, reducing transitive dependencies and unnecessary duplication.

## 5. One design consideration: `orders.total`

There is an important exception worth discussing in your report.

The `orders.total` column stores a value that can also be calculated from `order_items`:

```sql
SELECT
    order_id,
    SUM(quantity * price) AS calculated_total
FROM order_items
GROUP BY order_id;
```

This means the total is technically redundant.

We have retained it as a stored aggregate because it can make order retrieval more efficient. However, it introduces a consistency responsibility: whenever order items change, the order total must also be updated.

We'll address this in Portfolio 3 by maintaining the order total within the same database transaction as the order-item changes.

This is an intentional performance trade-off, not something to overlook when discussing normalization.
