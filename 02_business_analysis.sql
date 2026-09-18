-- ===============================================================================
-- Database: ZedRetailDB
-- Script: 02_business_analysis.sql
-- Description: Business analysis queries, KPI calculations, and performance metrics.
-- ===============================================================================

USE ZedRetailDB;

-- -------------------------------------------------------------------------------
-- 1. Total Net Revenue
-- -------------------------------------------------------------------------------
-- Calculate total net revenue for completed orders.
SELECT
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue
FROM Order_Details AS od
INNER JOIN Orders AS o 
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status = 'Completed';

-- -------------------------------------------------------------------------------
-- 2. Total Completed Orders
-- -------------------------------------------------------------------------------
-- Count total successfully completed order transactions.
SELECT
    COUNT(Order_ID) AS total_completed_orders
FROM Orders
WHERE Order_Status = 'Completed';

-- -------------------------------------------------------------------------------
-- 3. Average Order Value (AOV)
-- -------------------------------------------------------------------------------
-- Calculate average net revenue generated per order.
SELECT
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) / COUNT(DISTINCT o.Order_ID) AS average_order_value
FROM Order_Details AS od
INNER JOIN Orders AS o 
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status = 'Completed';

-- -------------------------------------------------------------------------------
-- 4. Top 5 Regions by Net Revenue
-- -------------------------------------------------------------------------------
-- Identify top 5 customer regions generating the highest revenue.
SELECT TOP 5
    c.Region AS customer_region,
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue
FROM Order_Details AS od
INNER JOIN Orders AS o 
    ON od.Order_ID = o.Order_ID
INNER JOIN Customers AS c 
    ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Completed'
GROUP BY c.Region
ORDER BY net_revenue DESC;

-- -------------------------------------------------------------------------------
-- 5. Monthly Revenue Trend
-- -------------------------------------------------------------------------------
-- Track monthly net revenue performance across years.
SELECT
    YEAR(o.Order_Date) AS sales_year,
    MONTH(o.Order_Date) AS sales_month,
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue
FROM Orders AS o
INNER JOIN Order_Details AS od 
    ON o.Order_ID = od.Order_ID
WHERE o.Order_Status = 'Completed'
GROUP BY 
    YEAR(o.Order_Date),
    MONTH(o.Order_Date)
ORDER BY 
    sales_year,
    sales_month;

-- -------------------------------------------------------------------------------
-- 6. Top 5 Best-Selling Products
-- -------------------------------------------------------------------------------
-- Retrieve top 5 products by net revenue and total sold quantity.
SELECT TOP 5
    p.Product_Name AS product_name,
    SUM(od.Quantity) AS total_quantity_sold,
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue
FROM Products AS p
INNER JOIN Order_Details AS od 
    ON p.Product_ID = od.Product_ID
INNER JOIN Orders AS o 
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status = 'Completed'
GROUP BY p.Product_Name
ORDER BY net_revenue DESC;

-- -------------------------------------------------------------------------------
-- 7. Total Discount Amount & Overall Discount Percentage
-- -------------------------------------------------------------------------------
-- Calculate absolute discount value and total discount percentage applied.
SELECT
    SUM(od.Quantity * ABS(od.Unit_Price) * od.Discount_Percent) AS total_discount_amount,
    (SUM(od.Quantity * ABS(od.Unit_Price) * od.Discount_Percent) 
     / SUM(od.Quantity * ABS(od.Unit_Price))) * 100 AS overall_discount_percentage
FROM Order_Details AS od
INNER JOIN Orders AS o 
    ON od.Order_ID = o.Order_ID
WHERE o.Order_Status = 'Completed';

-- -------------------------------------------------------------------------------
-- 8. Top 10 Customers by Net Revenue
-- -------------------------------------------------------------------------------
-- List overall top 10 highest-spending customers.
SELECT TOP 10
    c.Customer_ID AS customer_id,
    c.Customer_Name AS customer_name,
    c.Region AS customer_region,
    SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue
FROM Customers AS c
INNER JOIN Orders AS o 
    ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details AS od 
    ON o.Order_ID = od.Order_ID
WHERE o.Order_Status = 'Completed'
GROUP BY 
    c.Customer_ID,
    c.Customer_Name,
    c.Region
ORDER BY net_revenue DESC;

-- -------------------------------------------------------------------------------
-- 9. Top 10 Customers Per Region (Window Function)
-- -------------------------------------------------------------------------------
-- Rank and filter top 10 spending customers within each individual region.
WITH RegionalCustomerSales AS (
    SELECT
        c.Customer_Name AS customer_name,
        c.Region AS customer_region,
        SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) AS net_revenue,
        DENSE_RANK() OVER (
            PARTITION BY c.Region 
            ORDER BY SUM(od.Quantity * ABS(od.Unit_Price) * (1 - od.Discount_Percent)) DESC
        ) AS customer_rank_in_region
    FROM Customers AS c
    INNER JOIN Orders AS o 
        ON c.Customer_ID = o.Customer_ID
    INNER JOIN Order_Details AS od 
        ON o.Order_ID = od.Order_ID
    WHERE o.Order_Status = 'Completed'
    GROUP BY
        c.Customer_Name,
        c.Region
)
SELECT 
    customer_name,
    customer_region,
    net_revenue,
    customer_rank_in_region
FROM RegionalCustomerSales
WHERE customer_rank_in_region <= 10;