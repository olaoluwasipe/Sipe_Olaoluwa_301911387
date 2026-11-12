// History reads against the embedded customer documents.

print("=== One customer's history: Alice Johnson ===");
printjson(
  db.customer_order_history.findOne(
    { email: "alice@example.com" },
    { _id: 0 }
  )
);

print("=== Orders filtered by status: confirmed ===");
db.customer_order_history.aggregate([
  { $unwind: "$orders" },
  { $match: { "orders.status": "confirmed" } },
  {
    $project: {
      _id: 0,
      customer: "$name",
      orderId: "$orders.orderId",
      status: "$orders.status",
      total: "$orders.total",
      createdAt: "$orders.createdAt"
    }
  },
  { $sort: { orderId: 1 } }
]).forEach(printjson);

print("=== Total of stored order totals for Alice Johnson ===");
db.customer_order_history.aggregate([
  { $match: { email: "alice@example.com" } },
  { $unwind: "$orders" },
  {
    $group: {
      _id: { name: "$name", email: "$email" },
      orderCount: { $sum: 1 },
      totalSpend: { $sum: "$orders.total" }
    }
  }
]).forEach(printjson);
