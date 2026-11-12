# ShopFlow customer order history in MongoDB

MongoDB stores one document per customer. The orders and line items for that customer are embedded in the document. This collection is a copy of history for reading. It does not replace the PostgreSQL shop.

## Example document

Alice Johnson's document, copied from the sample orders:

```json
{
  "customerId": 1,
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "orders": [
    {
      "orderId": 1,
      "status": "confirmed",
      "total": 32000.00,
      "createdAt": "2026-11-11T06:08:25.643Z",
      "items": [
        { "productId": 1, "productName": "Wireless Mouse", "quantity": 2, "price": 8500.00 },
        { "productId": 2, "productName": "Mechanical Keyboard", "quantity": 1, "price": 15000.00 }
      ]
    },
    {
      "orderId": 20006,
      "status": "confirmed",
      "total": 2400.00,
      "createdAt": "2026-11-12T08:38:15.671Z",
      "items": [
        { "productId": 7, "productName": "Notebook", "quantity": 2, "price": 1200.00 }
      ]
    }
  ]
}
```

`customerId` and `orderId` are the PostgreSQL primary keys, so a history row can be traced back to the relational order.

## Fields copied from ShopFlow

- Customer: `customers.id`, `name`, `email`.
- Order: `orders.id`, `status`, `total`, `created_at`.
- Line: `order_items.product_id`, the product name, `quantity`, and the price stored on the line.

The line price is the price charged on that order. It is not the product's current selling price.

The seed has the five named customers and their sample orders: orders 1 to 5, plus Alice's later Notebook order 20006. The generated benchmark orders are not copied.

## Fields that stay in PostgreSQL

- `products.stock` and `products.price`.
- `categories`.
- `payments`, including payment status and amount.
- `inventory_logs`.

## Why this model fits history reads

A customer history read wants the customer, the orders, and the lines together. Embedding them means that read is one document, with no join.

Stock checks and payments stay in PostgreSQL because those writes need transactions. Portfolio 3 reduced stock, wrote the inventory log, and set `orders.total` in one transaction, and rolled the whole order back when stock was too low. A document copy of history cannot lock the product row or keep the payment consistent with the order. Those operations stay on the PostgreSQL primary data.
