/* =================================================================
   DecodeLabs Data Analytics Internship — Project 3
   SQL Data Analysis — E-Commerce Orders Database (SQLite dialect)
   =================================================================
   Database : orders.db
   Table    : orders  (1,200 rows)

   Columns:
     OrderID, Date, CustomerID, Product, Quantity, UnitPrice,
     ShippingAddress, PaymentMethod, OrderStatus, TrackingNumber,
     ItemsInCart, CouponCode, ReferralSource, TotalPrice, HasCoupon

   This file is organized by requirement:
     A. Basic SELECT
     B. Filtering with WHERE
     C. Sorting with ORDER BY
     D. Grouping with GROUP BY
     E. Aggregations: COUNT, SUM, AVG
     F. GROUP BY + HAVING (filtering aggregated buckets)
     G. Advanced / combined queries (subqueries, CASE, multi-clause)

   Every query can be run standalone against orders.db, e.g.:
     sqlite3 orders.db < project3_queries.sql
   ================================================================= */


-- =================================================================
-- A. BASIC SELECT
-- =================================================================

-- A1. Preview the raw table structure (first 10 rows, all columns)
SELECT *
FROM orders
LIMIT 10;

-- A2. Select only the business-relevant columns for a shipment lookup
SELECT OrderID, CustomerID, Product, TrackingNumber, OrderStatus
FROM orders
LIMIT 10;

-- A3. Distinct values — what products do we sell?
SELECT DISTINCT Product
FROM orders;

-- A4. Distinct values — what marketing channels refer customers?
SELECT DISTINCT ReferralSource
FROM orders;


-- =================================================================
-- B. FILTERING WITH WHERE
-- =================================================================

-- B1. All orders placed with a Credit Card
SELECT OrderID, CustomerID, Product, TotalPrice, PaymentMethod
FROM orders
WHERE PaymentMethod = 'Credit Card';

-- B2. High-value orders over $2,000
SELECT OrderID, Product, Quantity, UnitPrice, TotalPrice
FROM orders
WHERE TotalPrice > 2000;

-- B3. Cancelled OR Returned orders (the "at-risk" segment)
SELECT OrderID, Product, OrderStatus, TotalPrice
FROM orders
WHERE OrderStatus IN ('Cancelled', 'Returned');

-- B4. Orders placed in 2024 only
SELECT OrderID, Date, TotalPrice
FROM orders
WHERE Date >= '2024-01-01' AND Date < '2025-01-01';

-- B5. Orders that used a coupon (CouponCode is not blank)
SELECT OrderID, CouponCode, TotalPrice
FROM orders
WHERE CouponCode IS NOT NULL;

-- B6. Orders that used NO coupon
SELECT OrderID, TotalPrice
FROM orders
WHERE CouponCode IS NULL;

-- B7. Pattern matching — customers shipped to an address containing "Main St"
SELECT OrderID, ShippingAddress
FROM orders
WHERE ShippingAddress LIKE '%Main St%'
LIMIT 10;

-- B8. Compound filter — large Laptop orders paid online
SELECT OrderID, Product, Quantity, PaymentMethod, TotalPrice
FROM orders
WHERE Product = 'Laptop' AND PaymentMethod = 'Online' AND Quantity >= 3;


-- =================================================================
-- C. SORTING WITH ORDER BY
-- =================================================================

-- C1. Top 10 highest-value orders
SELECT OrderID, Product, TotalPrice
FROM orders
ORDER BY TotalPrice DESC
LIMIT 10;

-- C2. 10 lowest-value orders
SELECT OrderID, Product, TotalPrice
FROM orders
ORDER BY TotalPrice ASC
LIMIT 10;

-- C3. Most recent orders first
SELECT OrderID, Date, Product, TotalPrice
FROM orders
ORDER BY Date DESC
LIMIT 10;

-- C4. Multi-column sort — by Product, then by TotalPrice descending within each product
SELECT OrderID, Product, TotalPrice
FROM orders
ORDER BY Product ASC, TotalPrice DESC
LIMIT 20;


-- =================================================================
-- D. GROUPING WITH GROUP BY
-- =================================================================

-- D1. Distinct order-status buckets
SELECT OrderStatus
FROM orders
GROUP BY OrderStatus;

-- D2. Orders bucketed by Product
SELECT Product
FROM orders
GROUP BY Product;

-- D3. Orders bucketed by Product AND OrderStatus (two-level grouping)
SELECT Product, OrderStatus
FROM orders
GROUP BY Product, OrderStatus
ORDER BY Product, OrderStatus;


-- =================================================================
-- E. AGGREGATIONS: COUNT, SUM, AVG
-- =================================================================

-- E1. Total number of orders in the database
SELECT COUNT(*) AS total_orders
FROM orders;

-- E2. Total revenue across all orders
SELECT SUM(TotalPrice) AS total_revenue
FROM orders;

-- E3. Average order value
SELECT ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders;

-- E4. Order count, total revenue, and average order value BY PRODUCT
SELECT
    Product,
    COUNT(*)                    AS order_count,
    SUM(TotalPrice)              AS total_revenue,
    ROUND(AVG(TotalPrice), 2)    AS avg_order_value
FROM orders
GROUP BY Product
ORDER BY total_revenue DESC;

-- E5. Order count and revenue BY PAYMENT METHOD
SELECT
    PaymentMethod,
    COUNT(*)                 AS order_count,
    SUM(TotalPrice)           AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders
GROUP BY PaymentMethod
ORDER BY total_revenue DESC;

-- E6. Order count and revenue BY ORDER STATUS
SELECT
    OrderStatus,
    COUNT(*)                 AS order_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct_of_all_orders,
    SUM(TotalPrice)           AS total_revenue
FROM orders
GROUP BY OrderStatus
ORDER BY order_count DESC;

-- E7. Order count and revenue BY REFERRAL SOURCE (marketing channel)
SELECT
    ReferralSource,
    COUNT(*)                  AS order_count,
    SUM(TotalPrice)            AS total_revenue,
    ROUND(AVG(TotalPrice), 2)  AS avg_order_value
FROM orders
GROUP BY ReferralSource
ORDER BY total_revenue DESC;

-- E8. Monthly order volume and revenue (time-series aggregation)
SELECT
    strftime('%Y-%m', Date)   AS year_month,
    COUNT(*)                   AS order_count,
    SUM(TotalPrice)             AS monthly_revenue
FROM orders
GROUP BY year_month
ORDER BY year_month;

-- E9. Coupon usage impact — average order value with vs. without a coupon
SELECT
    CASE WHEN CouponCode IS NULL THEN 'No Coupon' ELSE 'Used Coupon' END AS coupon_status,
    COUNT(*)                  AS order_count,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders
GROUP BY coupon_status;

-- E10. Revenue contribution by coupon code (SAVE10, WINTER15, FREESHIP)
SELECT
    COALESCE(CouponCode, 'No Coupon') AS coupon_code,
    COUNT(*)                           AS order_count,
    SUM(TotalPrice)                     AS total_revenue,
    ROUND(100.0 * SUM(TotalPrice) / (SELECT SUM(TotalPrice) FROM orders), 1) AS pct_of_total_revenue
FROM orders
GROUP BY coupon_code
ORDER BY total_revenue DESC;


-- =================================================================
-- F. GROUP BY + HAVING (filtering on aggregated results)
-- =================================================================

-- F1. Products that generated more than $170,000 in total revenue
SELECT
    Product,
    SUM(TotalPrice) AS total_revenue
FROM orders
GROUP BY Product
HAVING SUM(TotalPrice) > 170000
ORDER BY total_revenue DESC;

-- F2. Referral sources with an average order value above $250
SELECT
    ReferralSource,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    COUNT(*) AS order_count
FROM orders
GROUP BY ReferralSource
HAVING AVG(TotalPrice) > 250
ORDER BY avg_order_value DESC;

-- F3. Months with more than 45 orders placed (high-volume months)
SELECT
    strftime('%Y-%m', Date) AS year_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY year_month
HAVING COUNT(*) > 45
ORDER BY order_count DESC;

-- F4. Payment methods used in more than 235 orders
SELECT
    PaymentMethod,
    COUNT(*) AS order_count
FROM orders
GROUP BY PaymentMethod
HAVING COUNT(*) > 235
ORDER BY order_count DESC;


-- =================================================================
-- G. ADVANCED / COMBINED QUERIES
-- =================================================================

-- G1. Top revenue-generating product WITHIN each order status
--     (illustrates GROUP BY + aggregation + filtering combined)
SELECT
    OrderStatus,
    Product,
    COUNT(*)         AS order_count,
    SUM(TotalPrice)   AS revenue
FROM orders
GROUP BY OrderStatus, Product
ORDER BY OrderStatus, revenue DESC;

-- G2. Rank products by revenue using a subquery in SELECT
SELECT
    Product,
    SUM(TotalPrice) AS total_revenue,
    ROUND(100.0 * SUM(TotalPrice) / (SELECT SUM(TotalPrice) FROM orders), 2) AS pct_of_total_revenue
FROM orders
GROUP BY Product
ORDER BY total_revenue DESC;

-- G3. Orders placed above the overall average order value (correlated filter via subquery)
SELECT OrderID, Product, TotalPrice
FROM orders
WHERE TotalPrice > (SELECT AVG(TotalPrice) FROM orders)
ORDER BY TotalPrice DESC
LIMIT 10;

-- G4. Cancellation/return rate BY PRODUCT — surfaces which products have fulfillment problems
SELECT
    Product,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN OrderStatus IN ('Cancelled', 'Returned') THEN 1 ELSE 0 END) AS cancelled_or_returned,
    ROUND(100.0 * SUM(CASE WHEN OrderStatus IN ('Cancelled', 'Returned') THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_cancelled_or_returned
FROM orders
GROUP BY Product
ORDER BY pct_cancelled_or_returned DESC;

-- G5. Customer-level summary — top 10 customers by total spend
--     (demonstrates GROUP BY on a non-obvious key + HAVING + ORDER BY + LIMIT together)
SELECT
    CustomerID,
    COUNT(*)                 AS order_count,
    SUM(TotalPrice)           AS total_spend,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value
FROM orders
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY total_spend DESC
LIMIT 10;

-- G6. Quarter-over-quarter revenue trend
SELECT
    (CAST(strftime('%Y', Date) AS INTEGER))                          AS year,
    ((CAST(strftime('%m', Date) AS INTEGER) - 1) / 3) + 1              AS quarter,
    COUNT(*)                                                          AS order_count,
    SUM(TotalPrice)                                                    AS revenue
FROM orders
GROUP BY year, quarter
ORDER BY year, quarter;
