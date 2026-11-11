 Sort  (cost=564.99..565.04 rows=20 width=47) (actual time=3.952..3.953 rows=20 loops=1)
   Sort Key: o.id DESC
   Sort Method: quicksort  Memory: 26kB
   Buffers: shared hit=312
   ->  Nested Loop  (cost=0.28..564.56 rows=20 width=47) (actual time=1.209..3.521 rows=20 loops=1)
         Buffers: shared hit=312
         ->  Index Scan using customers_pkey on customers c  (cost=0.28..8.29 rows=1 width=31) (actual time=0.135..0.136 rows=1 loops=1)
               Index Cond: (id = 500)
               Buffers: shared hit=6
         ->  Seq Scan on orders o  (cost=0.00..556.06 rows=20 width=32) (actual time=1.071..3.378 rows=20 loops=1)
               Filter: (customer_id = 500)
               Rows Removed by Filter: 19985
               Buffers: shared hit=306
 Planning:
   Buffers: shared hit=59
 Planning Time: 2.248 ms
 Execution Time: 4.090 ms
(17 rows)