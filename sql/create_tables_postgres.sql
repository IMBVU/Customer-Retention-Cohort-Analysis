-- Postgres DDL for Project 2: Retail Revelations
-- Import `online_retail_II.csv` into `retail_sales` after creating the table.

CREATE TABLE IF NOT EXISTS retail_sales (
  invoice TEXT,
  stockcode TEXT,
  description TEXT,
  quantity NUMERIC,
  invoicedate TIMESTAMP,
  price NUMERIC,
  customerid INT,
  country TEXT
);
