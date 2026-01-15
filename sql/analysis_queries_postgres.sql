-- Postgres analysis queries for Project 2: Retail Revelations
-- Assumes: table name `retail_sales`

CREATE OR REPLACE VIEW retail_sales_clean AS
SELECT *
FROM retail_sales
WHERE customerid IS NOT NULL
  AND invoicedate IS NOT NULL
  AND invoice IS NOT NULL
  AND invoice NOT LIKE 'C%'
  AND quantity > 0
  AND price > 0;

-- 1) Monthly KPIs
WITH invoice_kpi AS (
  SELECT
    invoice,
    DATE_TRUNC('month', MIN(invoicedate)) AS month,
    MIN(customerid) AS customerid,
    MIN(country) AS country,
    SUM(quantity * price) AS revenue
  FROM retail_sales_clean
  GROUP BY 1
),
monthly AS (
  SELECT
    month,
    COUNT(DISTINCT invoice) AS orders,
    COUNT(DISTINCT customerid) AS customers,
    SUM(revenue) AS revenue,
    AVG(revenue) AS aov
  FROM invoice_kpi
  GROUP BY 1
)
SELECT
  month,
  orders,
  customers,
  revenue,
  aov,
  (revenue / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)) - 1 AS mom_growth
FROM monthly
ORDER BY month;

-- 2) Repeat buyer rate
WITH invoice_cust AS (
  SELECT invoice, MIN(customerid) AS customerid
  FROM retail_sales_clean
  GROUP BY 1
),
cust_orders AS (
  SELECT customerid, COUNT(DISTINCT invoice) AS orders
  FROM invoice_cust
  GROUP BY 1
)
SELECT AVG(CASE WHEN orders >= 2 THEN 1.0 ELSE 0.0 END) AS repeat_buyer_rate
FROM cust_orders;

-- 3) Cohort retention (monthly)
WITH invoice_kpi AS (
  SELECT
    invoice,
    MIN(customerid) AS customerid,
    DATE_TRUNC('month', MIN(invoicedate)) AS order_month
  FROM retail_sales_clean
  GROUP BY 1
),
cohort AS (
  SELECT customerid, MIN(order_month) AS cohort_month
  FROM invoice_kpi
  GROUP BY 1
),
activity AS (
  SELECT
    c.cohort_month,
    i.order_month,
    (EXTRACT(YEAR FROM i.order_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
      + (EXTRACT(MONTH FROM i.order_month) - EXTRACT(MONTH FROM c.cohort_month)) AS month_index,
    COUNT(DISTINCT i.customerid) AS active_customers
  FROM invoice_kpi i
  JOIN cohort c ON c.customerid = i.customerid
  GROUP BY 1,2,3
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(DISTINCT customerid) AS cohort_size
  FROM cohort
  GROUP BY 1
)
SELECT
  a.cohort_month,
  a.month_index,
  cs.cohort_size,
  a.active_customers,
  (a.active_customers::numeric / NULLIF(cs.cohort_size, 0)) AS retention_rate
FROM activity a
JOIN cohort_sizes cs USING (cohort_month)
WHERE a.month_index >= 0
ORDER BY 1,2;

-- 4) Top products
SELECT
  stockcode,
  description,
  SUM(quantity * price) AS revenue,
  SUM(quantity) AS qty,
  COUNT(DISTINCT invoice) AS orders
FROM retail_sales_clean
GROUP BY 1,2
ORDER BY revenue DESC
LIMIT 25;

-- 5) Revenue by country
SELECT
  country,
  SUM(quantity * price) AS revenue,
  COUNT(DISTINCT invoice) AS orders,
  COUNT(DISTINCT customerid) AS customers
FROM retail_sales_clean
GROUP BY 1
ORDER BY revenue DESC;
