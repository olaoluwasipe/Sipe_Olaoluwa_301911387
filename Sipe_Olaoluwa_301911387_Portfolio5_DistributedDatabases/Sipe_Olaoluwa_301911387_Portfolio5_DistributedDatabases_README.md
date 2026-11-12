# Portfolio 5: Distributed and Cloud Databases

A ShopFlow primary database and one read replica. The brief accepts a discussion or a setup.

The full checklist for every portfolio is in `Sipe_Olaoluwa_301911387_PROJECT_PLAN.md`. Tick a finished task there as well as here.

## Plan

**Brief:** replication, sharding, availability, consistency, or a deployment, on the same case study. 6 marks.

**Still to do**

- [ ] `Sipe_Olaoluwa_301911387_Portfolio5_DistributedDatabases_design.md`.
- [ ] Data flow: orders, stock changes, and payments write to the primary. Product lists and sales reports read from the replica.
- [ ] State that the stock check before an order reads the primary. A replica can be behind the latest sale.
- [ ] State what replica lag does to Query 3, monthly revenue.
- [ ] Availability: what a primary failure means for new orders, and what the replica can still serve.
- [ ] Either add a second PostgreSQL container and show a replica read, or write in the design note that this portfolio is a design discussion and name what was not run.
- [ ] Write the run or reading steps in this README.

## How to run

Run steps will be written here if a replica container is built. If this portfolio stays a design discussion, this section will say that and point at the design note.
