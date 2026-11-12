// Sample ShopFlow customers and their order history.
// Re-running this file replaces the collection contents.

db.customer_order_history.deleteMany({});

db.customer_order_history.insertMany([
  {
    customerId: 1,
    name: "Alice Johnson",
    email: "alice@example.com",
    orders: [
      {
        orderId: 1,
        status: "confirmed",
        total: 32000.00,
        createdAt: ISODate("2026-11-11T06:08:25.643Z"),
        items: [
          { productId: 1, productName: "Wireless Mouse", quantity: 2, price: 8500.00 },
          { productId: 2, productName: "Mechanical Keyboard", quantity: 1, price: 15000.00 }
        ]
      },
      {
        orderId: 20006,
        status: "confirmed",
        total: 2400.00,
        createdAt: ISODate("2026-11-12T08:38:15.671Z"),
        items: [
          { productId: 7, productName: "Notebook", quantity: 2, price: 1200.00 }
        ]
      }
    ]
  },
  {
    customerId: 2,
    name: "Brian Smith",
    email: "brian@example.com",
    orders: [
      {
        orderId: 2,
        status: "processing",
        total: 104000.00,
        createdAt: ISODate("2026-11-10T05:08:25.643Z"),
        items: [
          { productId: 3, productName: "LED Monitor", quantity: 1, price: 95000.00 },
          { productId: 4, productName: "HDMI Cable", quantity: 2, price: 4500.00 }
        ]
      }
    ]
  },
  {
    customerId: 3,
    name: "Chika Okafor",
    email: "chika@example.com",
    orders: [
      {
        orderId: 3,
        status: "delivered",
        total: 143000.00,
        createdAt: ISODate("2026-11-09T04:08:25.643Z"),
        items: [
          { productId: 5, productName: "Office Chair", quantity: 1, price: 78000.00 },
          { productId: 6, productName: "Office Desk", quantity: 1, price: 65000.00 }
        ]
      }
    ]
  },
  {
    customerId: 4,
    name: "David Williams",
    email: "david@example.com",
    orders: [
      {
        orderId: 4,
        status: "confirmed",
        total: 11000.00,
        createdAt: ISODate("2026-11-08T03:08:25.643Z"),
        items: [
          { productId: 7, productName: "Notebook", quantity: 5, price: 1200.00 },
          { productId: 8, productName: "Pen Pack", quantity: 2, price: 2500.00 }
        ]
      }
    ]
  },
  {
    customerId: 5,
    name: "Esther Adeyemi",
    email: "esther@example.com",
    orders: [
      {
        orderId: 5,
        status: "pending",
        total: 22000.00,
        createdAt: ISODate("2026-11-07T02:08:25.643Z"),
        items: [
          { productId: 9, productName: "Wireless Headset", quantity: 1, price: 22000.00 }
        ]
      }
    ]
  }
]);

print("customer documents: " + db.customer_order_history.countDocuments());
