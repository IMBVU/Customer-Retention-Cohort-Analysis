# Retail Revelations: Decoding Online Sales Trends — Customer Retention & Cohort Analysis (Project 2)

This project is a recruiter-friendly retention analysis using a retail transaction dataset (invoices, products, customers, countries).
It demonstrates end-to-end analyst work: **cleaning messy transactions**, defining KPIs, building **cohort retention**, and producing BI-ready outputs.

## Business Questions
1. How are **revenue, orders, and active customers** trending month-to-month?
2. What share of customers become **repeat buyers**?
3. How does retention change across **first-purchase cohorts**?
4. Which products and countries drive the most revenue?

## Dataset
- Source file (expected locally): `online_retail_II.csv`

## Cleaning Rules (explicit)
- Drop rows missing `Customer ID` or `InvoiceDate`
- Remove cancelled invoices (Invoice starting with `C`)
- Keep only positive `Quantity` and `Price`

## KPI Definitions
- **Revenue** = `Quantity * Price` (line level), aggregated to invoice/month
- **Orders** = distinct invoices
- **AOV** = revenue / orders
- **Repeat buyer** = customer with 2+ distinct invoices
- **Cohort month** = customer’s first purchase month
- **Retention** = customer has ≥1 purchase in month index *k* after cohort month

## Outputs (ready for Power BI / Tableau)
- `data_processed/monthly_kpis.csv`
- `data_processed/customer_value.csv`
- `data_processed/cohort_retention_matrix.csv`
- `data_processed/top_products.csv`
- `figures/cohort_retention_heatmap.png`

## Quick Start
1. Keep `online_retail_II.csv` in the project root (same level as this README), or update the path in the notebook.
2. Run `notebooks/01_retail_revelations_cohort_retention.ipynb`

Generated: 2026-01-15
