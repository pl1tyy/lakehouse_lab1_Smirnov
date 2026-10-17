WITH 
bronze_customer AS (
    SELECT custkey, mktsegment 
    FROM lakekeeper.lakehouse.customer
),
bronze_orders AS (
    SELECT orderkey, custkey, orderdate, shippriority 
    FROM lakekeeper.lakehouse.orders
),
bronze_lineitem AS (
    SELECT orderkey, extendedprice, discount, shipdate 
    FROM lakekeeper.lakehouse.lineitem
),

silver_shipping_priority AS (
    SELECT 
        l.orderkey,
        l.extendedprice,
        l.discount,
        o.orderdate,
        o.shippriority
    FROM bronze_customer c
    JOIN bronze_orders o ON c.custkey = o.custkey
    JOIN bronze_lineitem l ON l.orderkey = o.orderkey
    WHERE c.mktsegment = 'BUILDING'
      AND o.orderdate < DATE '1995-03-15'
      AND l.shipdate > DATE '1995-03-15'
)

SELECT 
    orderkey,
    SUM(extendedprice * (1 - discount)) AS revenue,
    orderdate,
    shippriority
FROM silver_shipping_priority
GROUP BY orderkey, orderdate, shippriority
ORDER BY revenue DESC
LIMIT 10;