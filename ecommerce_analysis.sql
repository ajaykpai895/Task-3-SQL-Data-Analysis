

-- Q1. View first 10 rows of the dataset
SELECT * FROM sales LIMIT 10;


-- Q2. Total Revenue and Profit by Category (GROUP BY + ORDER BY)
SELECT 
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2)  AS Total_Profit
FROM sales
GROUP BY Category
ORDER BY Total_Revenue DESC;


-- Q3. Filter orders from South region only (WHERE)
SELECT 
    Order_ID, Customer_Name, State, Product_Name, Revenue
FROM sales
WHERE Region = 'South'
ORDER BY Revenue DESC
LIMIT 20;


-- Q4. Products with Revenue greater than 500 (WHERE + ORDER BY)
SELECT 
    Product_Name, Category, Quantity,
    ROUND(Revenue, 2) AS Revenue
FROM sales
WHERE Revenue > 500
ORDER BY Revenue DESC
LIMIT 20;


-- Q5. Total Quantity sold per Sub-Category (GROUP BY)
SELECT 
    Sub_Category,
    SUM(Quantity)          AS Total_Quantity,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Sub_Category
ORDER BY Total_Quantity DESC;


-- Q6. Count of orders per Region (GROUP BY + COUNT)
SELECT 
    Region,
    COUNT(Order_ID)        AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Region
ORDER BY Total_Revenue DESC;



-- Q7. Overall KPIs — Total Revenue, Profit, Orders, Avg Order Value
SELECT 
    ROUND(SUM(Revenue), 2)  AS Total_Revenue,
    ROUND(SUM(Profit), 2)   AS Total_Profit,
    COUNT(Order_ID)         AS Total_Orders,
    ROUND(AVG(Revenue), 2)  AS Avg_Revenue_Per_Order,
    ROUND(MAX(Revenue), 2)  AS Max_Order_Revenue,
    ROUND(MIN(Revenue), 2)  AS Min_Order_Revenue
FROM sales;


-- Q8. Average Profit by Region
SELECT 
    Region,
    ROUND(AVG(Profit), 2)  AS Avg_Profit,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    COUNT(Order_ID)        AS Order_Count
FROM sales
GROUP BY Region
ORDER BY Total_Revenue DESC;


-- Q9. Profit Margin % by Category (calculated aggregate)
SELECT 
    Category,
    ROUND(SUM(Revenue), 2)                       AS Total_Revenue,
    ROUND(SUM(Profit), 2)                        AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Revenue), 2) AS Profit_Margin_Pct
FROM sales
GROUP BY Category
ORDER BY Profit_Margin_Pct DESC;




-- Q10. Categories with Total Revenue above $20 Million (HAVING)
--      NOTE: HAVING filters AFTER grouping; WHERE filters BEFORE grouping
SELECT 
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Category
HAVING Total_Revenue > 20000000
ORDER BY Total_Revenue DESC;


-- Q11. Sub-Categories with more than 5000 orders (HAVING + COUNT)
SELECT 
    Sub_Category,
    COUNT(Order_ID)        AS Total_Orders,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Sub_Category
HAVING Total_Orders > 5000
ORDER BY Total_Orders DESC;


-- Q12. Customers who placed more than 3 orders (HAVING)
SELECT 
    Customer_Name,
    COUNT(Order_ID)        AS Order_Count,
    ROUND(SUM(Revenue), 2) AS Total_Spent
FROM sales
GROUP BY Customer_Name
HAVING Order_Count > 3
ORDER BY Total_Spent DESC
LIMIT 15;




-- First, create a second table to JOIN with
CREATE TABLE IF NOT EXISTS category_info (
    Category        TEXT PRIMARY KEY,
    Manager         TEXT,
    Target_Revenue  REAL,
    Budget          REAL
);

-- Insert manager/target data
INSERT OR IGNORE INTO category_info VALUES
    ('Electronics',        'Alice Johnson', 60000000, 5000000),
    ('Home & Furniture',   'Bob Smith',     50000000, 4000000),
    ('Clothing & Apparel', 'Carol White',   30000000, 3000000),
    ('Accessories',        'David Brown',   15000000, 2000000);


-- Q13. INNER JOIN — Sales performance vs targets
SELECT 
    s.Category,
    c.Manager,
    ROUND(SUM(s.Revenue), 2)  AS Total_Revenue,
    c.Target_Revenue,
    ROUND(SUM(s.Revenue) - c.Target_Revenue, 2) AS Revenue_Gap
FROM sales s
INNER JOIN category_info c ON s.Category = c.Category
GROUP BY s.Category
ORDER BY Total_Revenue DESC;


-- Q14. LEFT JOIN — All sales categories including any without a manager
SELECT 
    s.Category,
    c.Manager,
    ROUND(SUM(s.Revenue), 2) AS Total_Revenue
FROM sales s
LEFT JOIN category_info c ON s.Category = c.Category
GROUP BY s.Category
ORDER BY Total_Revenue DESC;


-- Q15. RIGHT JOIN simulation (SQLite uses LEFT JOIN reversed)
--      All managers even if they have no sales
SELECT 
    c.Category,
    c.Manager,
    ROUND(SUM(s.Revenue), 2) AS Total_Revenue
FROM category_info c
LEFT JOIN sales s ON s.Category = c.Category
GROUP BY c.Category
ORDER BY Total_Revenue DESC;



-- Q16. Products with Revenue ABOVE the overall average (subquery in WHERE)
SELECT 
    Product_Name, Category,
    ROUND(Revenue, 2) AS Revenue
FROM sales
WHERE Revenue > (SELECT AVG(Revenue) FROM sales)
ORDER BY Revenue DESC
LIMIT 15;


-- Q17. Top region by revenue (subquery in FROM)
SELECT Region, Total_Revenue
FROM (
    SELECT 
        Region,
        ROUND(SUM(Revenue), 2) AS Total_Revenue
    FROM sales
    GROUP BY Region
) AS region_summary
ORDER BY Total_Revenue DESC
LIMIT 1;


-- Q18. Average Revenue Per User / Customer (ARPU)
--      Answers: "How do you calculate average revenue per user in SQL?"
SELECT 
    ROUND(AVG(customer_revenue), 2) AS Avg_Revenue_Per_Customer
FROM (
    SELECT 
        Customer_Name,
        SUM(Revenue) AS customer_revenue
    FROM sales
    GROUP BY Customer_Name
) AS customer_totals;


-- Q19. Top 10 highest-spending customers vs overall average
SELECT 
    Customer_Name,
    ROUND(SUM(Revenue), 2) AS Total_Spent,
    ROUND((SELECT AVG(Revenue) FROM sales), 2) AS Overall_Avg
FROM sales
GROUP BY Customer_Name
HAVING Total_Spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(Revenue) AS customer_total
        FROM sales
        GROUP BY Customer_Name
    )
)
ORDER BY Total_Spent DESC
LIMIT 10;


-- Q20. Categories performing above company average margin (nested subquery)
SELECT Category, Profit_Margin_Pct
FROM (
    SELECT 
        Category,
        ROUND(SUM(Profit) * 100.0 / SUM(Revenue), 2) AS Profit_Margin_Pct
    FROM sales
    GROUP BY Category
) AS margins
WHERE Profit_Margin_Pct > (
    SELECT ROUND(SUM(Profit) * 100.0 / SUM(Revenue), 2)
    FROM sales
)
ORDER BY Profit_Margin_Pct DESC;



-- Q21. View: Category Performance Summary
CREATE VIEW IF NOT EXISTS vw_category_performance AS
SELECT 
    Category,
    ROUND(SUM(Revenue), 2)                       AS Total_Revenue,
    ROUND(SUM(Profit), 2)                        AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Revenue), 2) AS Profit_Margin_Pct,
    COUNT(Order_ID)                              AS Total_Orders,
    ROUND(AVG(Revenue), 2)                       AS Avg_Order_Value
FROM sales
GROUP BY Category;

-- Query the view
SELECT * FROM vw_category_performance ORDER BY Total_Revenue DESC;


-- Q22. View: Regional Sales Summary
CREATE VIEW IF NOT EXISTS vw_regional_summary AS
SELECT 
    Region,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2)  AS Total_Profit,
    ROUND(AVG(Profit), 2)  AS Avg_Profit,
    COUNT(Order_ID)        AS Order_Count
FROM sales
GROUP BY Region;

-- Query the view
SELECT * FROM vw_regional_summary ORDER BY Total_Revenue DESC;


-- Q23. View: Top 10 Products by Revenue
CREATE VIEW IF NOT EXISTS vw_top_products AS
SELECT 
    Product_Name, Category, Sub_Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    SUM(Quantity)          AS Total_Units_Sold
FROM sales
GROUP BY Product_Name
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Query the view
SELECT * FROM vw_top_products;




-- Q24. Check for NULL values in each column
SELECT 
    SUM(CASE WHEN Order_ID      IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
    SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS Null_Customer,
    SUM(CASE WHEN Revenue       IS NULL THEN 1 ELSE 0 END) AS Null_Revenue,
    SUM(CASE WHEN Profit        IS NULL THEN 1 ELSE 0 END) AS Null_Profit,
    SUM(CASE WHEN Region        IS NULL THEN 1 ELSE 0 END) AS Null_Region
FROM sales;


-- Q25. Replace NULLs with 0 using COALESCE (safe aggregation)
SELECT 
    Category,
    ROUND(SUM(COALESCE(Revenue, 0)), 2) AS Total_Revenue,
    ROUND(AVG(COALESCE(Profit,  0)), 2) AS Avg_Profit
FROM sales
GROUP BY Category;


-- Q26. Filter out rows where Profit is NULL or zero
SELECT Order_ID, Product_Name, Revenue, Profit
FROM sales
WHERE Profit IS NOT NULL AND Profit > 0
ORDER BY Profit DESC
LIMIT 10;


-- Q27. Create indexes to speed up frequent queries
CREATE INDEX IF NOT EXISTS idx_category     ON sales(Category);
CREATE INDEX IF NOT EXISTS idx_region       ON sales(Region);
CREATE INDEX IF NOT EXISTS idx_revenue      ON sales(Revenue);
CREATE INDEX IF NOT EXISTS idx_customer     ON sales(Customer_Name);
CREATE INDEX IF NOT EXISTS idx_product      ON sales(Product_Name);
CREATE INDEX IF NOT EXISTS idx_order_date   ON sales(Order_Date);

-- Verify indexes were created
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index';


-- Q28. Query that benefits from index — now runs faster
SELECT 
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
WHERE Category = 'Electronics'
GROUP BY Category;



-- Q29. Running total of revenue by category (window-style with subquery)
SELECT 
    a.Category,
    ROUND(SUM(a.Revenue), 2) AS Category_Revenue,
    ROUND((
        SELECT SUM(b.Revenue) FROM sales b
        WHERE b.Category <= a.Category
    ), 2) AS Running_Total
FROM sales a
GROUP BY a.Category
ORDER BY a.Category;


-- Q30. State-level revenue — Top 10 States
SELECT 
    State,
    Region,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    COUNT(Order_ID)        AS Total_Orders
FROM sales
GROUP BY State
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Q31. Year-wise Revenue (extracted from Order_Date)
SELECT 
    SUBSTR(Order_Date, 7, 2) AS Year_Short,
    ROUND(SUM(Revenue), 2)   AS Total_Revenue,
    COUNT(Order_ID)          AS Total_Orders
FROM sales
GROUP BY Year_Short
ORDER BY Year_Short;


-- Q32. Best Sub-Category per Category
SELECT Category, Sub_Category, Total_Revenue
FROM (
    SELECT 
        Category,
        Sub_Category,
        ROUND(SUM(Revenue), 2) AS Total_Revenue,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Revenue) DESC) AS rnk
    FROM sales
    GROUP BY Category, Sub_Category
)
WHERE rnk = 1;


