-- ===============================================================================
-- Database: ZedRetailDB
-- Script: 01_data_exploration.sql
-- Description: Initial data profiling, integrity checks, and anomaly detection.
-- ===============================================================================

USE ZedRetailDB;

-- -------------------------------------------------------------------------------
-- 1. Table Row Counts Overview
-- -------------------------------------------------------------------------------
-- Check total record count across all database tables.
SELECT 'Customers' AS table_name, COUNT(*) AS total_rows FROM Customers
UNION ALL
SELECT 'Order_Details', COUNT(*) FROM Order_Details
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Returns', COUNT(*) FROM Returns
UNION ALL
SELECT 'Sales_Representatives', COUNT(*) FROM Sales_Representatives;

-- -------------------------------------------------------------------------------
-- 2. Customers Table Checks
-- -------------------------------------------------------------------------------
-- Check for duplicate primary keys in Customers table.
SELECT 
    Customer_ID,
    COUNT(*) AS duplicate_count
FROM Customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- Inspect distinct categorical values.
SELECT DISTINCT Gender FROM Customers;
SELECT DISTINCT City FROM Customers ORDER BY City;
SELECT DISTINCT Region FROM Customers;
SELECT DISTINCT Customer_Segment FROM Customers;

-- Validate age ranges for invalid entries (< 18 or > 100).
SELECT 
    Customer_ID,
    Customer_Name,
    Age
FROM Customers
WHERE Age < 18 OR Age > 100;

-- Identify invalid future signup dates.
SELECT *
FROM Customers
WHERE Signup_Date > CAST(GETDATE() AS DATE);

-- Count missing values (NULLs) per column in Customers table.
SELECT
    COUNT(CASE WHEN Customer_ID IS NULL THEN 1 END) AS missing_customer_id,
    COUNT(CASE WHEN Customer_Name IS NULL THEN 1 END) AS missing_customer_name,
    COUNT(CASE WHEN Gender IS NULL THEN 1 END) AS missing_gender,
    COUNT(CASE WHEN Age IS NULL THEN 1 END) AS missing_age,
    COUNT(CASE WHEN City IS NULL THEN 1 END) AS missing_city,
    COUNT(CASE WHEN Region IS NULL THEN 1 END) AS missing_region,
    COUNT(CASE WHEN Customer_Segment IS NULL THEN 1 END) AS missing_customer_segment,
    COUNT(CASE WHEN Signup_Date IS NULL THEN 1 END) AS missing_signup_date
FROM Customers;

-- -------------------------------------------------------------------------------
-- 3. Order_Details Table Checks
-- -------------------------------------------------------------------------------
-- Check for duplicate line items in Order_Details.
SELECT
    Order_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount_Percent,
    COUNT(*) AS duplicate_count
FROM Order_Details
GROUP BY
    Order_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount_Percent
HAVING COUNT(*) > 1;

-- Check for non-positive quantities.
SELECT Quantity 
FROM Order_Details
WHERE Quantity <= 0;

-- Check for non-positive or negative prices.
SELECT Unit_Price 
FROM Order_Details
WHERE Unit_Price <= 0
ORDER BY Unit_Price DESC;

-- Validate discount percentage range (must be between 0 and 1).
SELECT Discount_Percent 
FROM Order_Details
WHERE Discount_Percent < 0 OR Discount_Percent > 1;

-- Count missing values (NULLs) in Order_Details.
SELECT
    COUNT(CASE WHEN Order_ID IS NULL THEN 1 END) AS missing_order_id,
    COUNT(CASE WHEN Product_ID IS NULL THEN 1 END) AS missing_product_id,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS missing_quantity,
    COUNT(CASE WHEN Unit_Price IS NULL THEN 1 END) AS missing_unit_price,
    COUNT(CASE WHEN Discount_Percent IS NULL THEN 1 END) AS missing_discount_percent
FROM Order_Details;

-- -------------------------------------------------------------------------------
-- 4. Orders Table Checks
-- -------------------------------------------------------------------------------
-- Inspect distinct categorical attributes in Orders.
SELECT DISTINCT Payment_Method FROM Orders;
SELECT DISTINCT Shipping_City FROM Orders;
SELECT DISTINCT Shipping_Region FROM Orders;
SELECT DISTINCT Order_Status FROM Orders;

-- Identify invalid future order dates.
SELECT Order_ID, Order_Date 
FROM Orders
WHERE Order_Date > GETDATE();

-- Count missing values (NULLs) in key attributes of Orders.
SELECT
    COUNT(CASE WHEN Order_Date IS NULL THEN 1 END) AS missing_order_date,
    COUNT(CASE WHEN Customer_ID IS NULL THEN 1 END) AS missing_customer_id,
    COUNT(CASE WHEN Sales_Rep_ID IS NULL THEN 1 END) AS missing_sales_rep_id
FROM Orders;

-- -------------------------------------------------------------------------------
-- 5. Products Table Checks
-- -------------------------------------------------------------------------------
-- Check for duplicate product names.
SELECT
    Product_Name,
    COUNT(*) AS duplicate_count
FROM Products
GROUP BY Product_Name
HAVING COUNT(*) > 1;

-- Inspect distinct product categories and subcategories.
SELECT DISTINCT Category FROM Products;
SELECT DISTINCT Subcategory FROM Products;

-- Check for non-positive unit costs.
SELECT Product_ID, Unit_Cost 
FROM Products
WHERE Unit_Cost <= 0;

-- Identify pricing anomalies where unit cost exceeds or equals sales unit price.
SELECT Product_ID, Product_Name, Unit_Cost, Unit_Price 
FROM Products
WHERE Unit_Cost >= Unit_Price;

-- Check for non-positive product unit prices.
SELECT Product_ID, Unit_Price 
FROM Products
WHERE Unit_Price <= 0;

-- Check for future product launch dates.
SELECT Product_ID, Product_Launch_Date
FROM Products
WHERE Product_Launch_Date > GETDATE();

-- Count missing values (NULLs) in Products table.
SELECT
    COUNT(CASE WHEN Product_Name IS NULL THEN 1 END) AS missing_product_name,
    COUNT(CASE WHEN Category IS NULL THEN 1 END) AS missing_category,
    COUNT(CASE WHEN Subcategory IS NULL THEN 1 END) AS missing_subcategory,
    COUNT(CASE WHEN Unit_Cost IS NULL THEN 1 END) AS missing_unit_cost,
    COUNT(CASE WHEN Unit_Price IS NULL THEN 1 END) AS missing_unit_price,
    COUNT(CASE WHEN Supplier IS NULL THEN 1 END) AS missing_supplier,
    COUNT(CASE WHEN Product_Launch_Date IS NULL THEN 1 END) AS missing_product_launch_date
FROM Products;

-- -------------------------------------------------------------------------------
-- 6. Returns Table Checks
-- -------------------------------------------------------------------------------
-- Identify invalid future return dates.
SELECT Return_ID, Return_Date 
FROM Returns
WHERE Return_Date > GETDATE();

-- Check for non-positive return quantities.
SELECT Return_Quantity 
FROM Returns
WHERE Return_Quantity <= 0;

-- Inspect distinct return reasons.
SELECT DISTINCT Return_Reason FROM Returns;

-- Count missing values (NULLs) in Returns table.
SELECT
    COUNT(CASE WHEN Order_ID IS NULL THEN 1 END) AS missing_order_id,
    COUNT(CASE WHEN Product_ID IS NULL THEN 1 END) AS missing_product_id,
    COUNT(CASE WHEN Return_Date IS NULL THEN 1 END) AS missing_return_date,
    COUNT(CASE WHEN Return_Quantity IS NULL THEN 1 END) AS missing_return_quantity,
    COUNT(CASE WHEN Return_Reason IS NULL THEN 1 END) AS missing_return_reason
FROM Returns;

-- -------------------------------------------------------------------------------
-- 7. Sales Representatives Table Checks
-- -------------------------------------------------------------------------------
-- Check for duplicate or missing sales representative names.
SELECT
    Sales_Rep_Name,
    COUNT(*) AS duplicate_count
FROM Sales_Representatives
GROUP BY Sales_Rep_Name
HAVING COUNT(*) > 1 OR Sales_Rep_Name IS NULL;

-- Check for missing or invalid future hire dates.
SELECT Sales_Rep_ID, Hire_Date 
FROM Sales_Representatives
WHERE Hire_Date > GETDATE() OR Hire_Date IS NULL;

-- Check for missing or non-positive monthly targets.
SELECT Sales_Rep_ID, Target_Monthly 
FROM Sales_Representatives
WHERE Target_Monthly IS NULL OR Target_Monthly <= 0;