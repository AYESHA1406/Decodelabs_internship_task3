# Decodelabs_internship_task3

# 📊 Project 3 – SQL Data Analysis

> DecodeLabs Industrial Training Kit – Batch 2026

## Overview

This project demonstrates how SQL can be used to analyze an e-commerce dataset containing **1,200 orders**. Unlike Project 2, which used Python (Pandas) for Exploratory Data Analysis (EDA), this project performs the analysis entirely with SQL using SQLite.

The objective is to extract meaningful business insights using SQL queries such as `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, and aggregate functions.

---

## Project Objective

The goal of this project is to analyze business data using SQL and answer real-world business questions. The project demonstrates how relational databases can be used to organize, filter, summarize, and interpret data for decision-making.

---

## Dataset

The project uses a SQLite database named **orders.db** containing a single table named **orders** with **1,200 records**.

| Column | Description |
|---------|-------------|
| OrderID | Unique order identifier |
| Date | Order date |
| CustomerID | Customer identifier |
| Product | Product purchased |
| Quantity | Number of units ordered |
| UnitPrice | Price per unit |
| ShippingAddress | Delivery address |
| PaymentMethod | Payment method |
| OrderStatus | Current order status |
| TrackingNumber | Shipment tracking ID |
| ItemsInCart | Number of items in cart |
| CouponCode | Applied coupon |
| ReferralSource | Customer acquisition source |
| TotalPrice | Quantity × Unit Price |
| HasCoupon | Indicates whether a coupon was used |

---

## Technologies Used

- SQL
- SQLite
- Python
- Pandas
- DB Browser for SQLite
- VS Code

---

## SQL Concepts Covered

- SELECT
- DISTINCT
- WHERE
- IN
- LIKE
- BETWEEN
- ORDER BY
- GROUP BY
- HAVING
- COUNT()
- SUM()
- AVG()
- CASE
- Subqueries
- Multi-column Grouping

---

## SQL Execution Order

```
FROM
  ↓
WHERE
  ↓
GROUP BY
  ↓
HAVING
  ↓
SELECT
  ↓
ORDER BY
```

---

## Project Structure

The project contains **39 SQL queries** organized into seven sections.

| Section | Description |
|---------|-------------|
| A | Basic SELECT and DISTINCT |
| B | WHERE filtering |
| C | ORDER BY |
| D | GROUP BY |
| E | Aggregate Functions |
| F | HAVING |
| G | Advanced SQL Queries |

---

## Key Findings

### Revenue Analysis

- Chair and Printer generated the highest overall revenue.
- Phone generated the lowest revenue among all products.

### Order Status

- Approximately **41.4%** of all orders were either cancelled or returned.
- This pattern appeared consistently across all products, indicating a business process issue rather than a product-specific problem.

### Payment Methods

- Credit Card generated the highest revenue.
- Revenue distribution across payment methods was relatively balanced.

### Coupon Analysis

- FREESHIP produced the highest revenue among coupon users.
- Orders without coupons still accounted for a significant portion of total revenue.

### High-Value Orders

- 180 orders exceeded **$2,000**.
- Highest order value: **$3,390.95**
- Lowest order value: **$11.39**

### Customer Insights

- Most customers placed only one order.
- A small number of repeat customers generated higher overall spending.

---

## Project Files

```
Project-3-SQL-Analysis/
│
├── orders.db
├── project3_queries.sql
├── run_queries.py
├── SQL_Analysis_Report.docx
├── README.md
├── query_results/
└── charts/
```

---

## Running the Project

### Clone the repository

```bash
git clone https://github.com/your-username/project3-sql-analysis.git
```

### Install dependencies

```bash
pip install pandas openpyxl
```

### Create the database

```python
import pandas as pd
import sqlite3

df = pd.read_excel("Dataset_for_Data_Analytics.xlsx")
df["HasCoupon"] = df["CouponCode"].notna()

conn = sqlite3.connect("orders.db")
df.to_sql("orders", conn, if_exists="replace", index=False)
conn.close()
```

### Execute all SQL queries

```bash
python run_queries.py
```

Or run directly using SQLite:

```bash
sqlite3 orders.db < project3_queries.sql
```

---

## What I Learned

This project helped me gain practical experience in:

- Writing SQL queries
- Filtering and sorting data
- Grouping and aggregating records
- Analyzing business performance
- Working with SQLite databases
- Extracting business insights from data

---

## Business Recommendations

- Investigate the high cancellation and return rates.
- Continue promoting high-performing products such as Chair and Printer.
- Maintain multiple payment options since customer preferences are balanced.
- Evaluate the effectiveness of coupon campaigns.
- Develop strategies to improve customer retention.

---

## Future Improvements

- Build an interactive Power BI dashboard.
- Add SQL views for reusable analysis.
- Integrate with a larger database system such as MySQL or PostgreSQL.
- Perform customer segmentation.
- Develop predictive analytics models.
