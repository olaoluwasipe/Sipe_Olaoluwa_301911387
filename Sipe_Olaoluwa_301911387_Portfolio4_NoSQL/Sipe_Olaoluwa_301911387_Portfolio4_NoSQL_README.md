# Portfolio 4: NoSQL and Advanced Data Models

MongoDB customer order history for the same ShopFlow shop. Stock and payments stay in PostgreSQL.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** a NoSQL model of the same case study, a working example, saved output, and why that model fits. 7 marks.

**Still to do**

- [ ] Add a MongoDB service to `Sipe_Olaoluwa_301911387_Portfolio1_DatabaseDesign_compose.yml`.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_model.md`. One customer document with orders and line items embedded. Say which fields are copied from ShopFlow and which stay relational.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_seed.js` with a few customer documents taken from the sample shop data.
- [ ] `Sipe_Olaoluwa_301911387_Portfolio4_NoSQL_queries.js`: one customer's history, orders filtered by status, and total spend for a customer.
- [ ] Save the query output.
- [ ] Suitability note in the model file: history reads fit a document; stock checks and payments stay in PostgreSQL because they need transactions.
- [ ] Write the run steps in this README.

## How to run

Run steps will be written here when MongoDB is in Compose and the queries have been run.
