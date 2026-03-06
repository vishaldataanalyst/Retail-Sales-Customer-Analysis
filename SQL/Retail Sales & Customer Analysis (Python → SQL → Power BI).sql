-- PROBLEM STATEMENT
/*"Analyze retail transaction data to uncover sales trends,
 product performance, customer behavior, and regional revenue patterns, 
 and provide actionable business recommendations to drive revenue growth, optimize inventory,
 and improve customer loyalty. Implement RFM analysis to segment customers based on recency, frequency, and monetary value,
 identifying high-value and loyal customers for targeted strategies." */



create schema retail;
use retail;
CREATE TABLE retail_sales (
    Invoice VARCHAR(50),
    StockCode VARCHAR(50),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    Price DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100),
    TotalAmount DECIMAL(12,2)
);
SELECT * FROM retail_sales LIMIT 3;
SELECT COUNT(*) FROM retail_sales;
 SELECT SUM(TotalAmount) AS TotalRevenue
FROM retail_sales; 
-- total revenue is 8798233
SELECT COUNT(DISTINCT Invoice) AS TotalOrders
FROM retail_sales;
--  total orders are 19213
-- Correct way
SELECT SUM(TotalAmount)/COUNT(DISTINCT Invoice) AS AvgOrderValue
FROM retail_sales;
-- average order value is 457.9
 SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
       SUM(TotalAmount) AS Revenue,
       SUM(TotalAmount) - LAG(SUM(TotalAmount)) OVER (ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m')) AS MonthGrowth
FROM retail_sales
GROUP BY Month
ORDER BY Month;
/* sales tendency
time      revenue   month growth
2009-12	683504.01	
2010-01	555802.67	-127701.34
2010-02	504558.95	-51243.72
2010-03	696978.47	192419.52
2010-04	591982.00	-104996.47
2010-05	597833.38	5851.38
2010-06	636371.13	38537.75
2010-07	589736.17	-46634.96
2010-08	602224.60	12488.43
2010-09	829013.95	226789.35
2010-10	1033112.01	204098.06
2010-11	1166460.02	133348.01
2010-12	310656.37	-855803.65
*/
-- top 10 customers by revenue
select CustomerId,sum(TotalAmount) as Revenue from retail_sales 
group by CustomerId
order by sum(TotalAmount) desc limit 10;
/* they are top 10
customerid revenue
18102	349164.35
14646	248396.50
14156	196549.74
14911	152121.22
13694	131443.19
17511	84541.17
15061	83284.38
16684	80489.21
16754	65500.07
17949	60117.60 */
-- top 10customers who placeed many orders
select CustomerID ,count(distinct Invoice) as TotalOrders from retail_sales
group by CustomerId
order by  count(distinct Invoice) desc limit 10;
/* top 10
id      orders
14911	205
17850	155
12748	144
15311	121
13089	109
14156	102
14606	102
13694	94
17841	91
18102	89*/

SELECT SUM(TotalAmount) AS Refunds
FROM retail_sales
WHERE Quantity < 0;
-- there is no refund

-- Create a table for basic RFM metrics per customer
CREATE TABLE rfm_sql AS
SELECT 
    CustomerID,
    DATEDIFF(CURDATE(), MAX(InvoiceDate)) AS Recency,
    COUNT(DISTINCT Invoice) AS Frequency,
    SUM(Quantity * Price) AS Monetary
FROM retail_sales
GROUP BY CustomerID;
select * from rfm_sql limit 10;
select * from rfm_customers;
select * from retail_sales limit 3;
select Country,sum(TotalAmount) as TotalRevenue from retail_sales 
group by Country
order by sum(TotalAmount) desc 
limit 9;
select Description,sum(TotalAmount) as TotalRevenue from retail_sales 
group by Description
order by sum(TotalAmount) desc 
limit 7;
select Description, count(distinct(Invoice)) as TotalOrders from retail_sales 
group by Description
order by count(distinct(Invoice)) desc 
limit 5;
select * from rfm_customers limit 3;
select RFM_Score,count(CustomerID) as TotalCustomers from rfm_customers
group by RFM_Score
order by count(CustomerID) desc limit 10;