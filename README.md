# Task 3 — SQL for Data Analysis 🗄️

## 📌 Internship
**Elevate Labs — Data Analyst Internship**

---

## 🎯 Objective
Use SQL queries to extract and analyze data from a database, covering real-world business questions using structured query language.

---

## 🛠️ Tools Used
| Tool | Purpose |
|------|---------|
| DB Browser for SQLite | GUI to run and visualize SQL queries |
| SQLite | Database engine (free, no server needed) |
| Dataset | product_sales_dataset_final.csv (200,000 rows) |

---

## 📁 Repository Structure

```
Task-3-SQL-Data-Analysis/
│
├── ecommerce.db              → SQLite database (200,000 rows loaded)
├── ecommerce.sqbpro          → DB Browser project file
├── ecommerce_analysis.sql    → All 32 SQL queries
├── README.md                 → This file
│
└── screenshots/
    ├── Image1.png
    ├── Image2.png
    ├── Image3.png
    ├── Image4.png
    ├── Image5.png
    ├── Image6.png
    ├── Image7.png
    ├── Image8.png
    ├── Image9.png
    ├── Image10.png
    ├── Image11.png
    └── Image12.png
```

---

## 🗃️ Dataset Overview

| Column | Description |
|--------|-------------|
| Order_ID | Unique order identifier |
| Order_Date | Date of purchase |
| Customer_Name | Name of the customer |
| City / State / Region | Location details |
| Category | Product category (4 types) |
| Sub_Category | Product sub-category |
| Product_Name | Name of product |
| Quantity | Units ordered |
| Unit_Price | Price per unit |
| Revenue | Total order revenue |
| Profit | Net profit per order |

**Total Records:** 200,000  
**Categories:** Electronics, Home & Furniture, Clothing & Apparel, Accessories  
**Regions:** East, West, Centre, South  

---

## 📊 SQL Concepts Covered

### 1️⃣ Basic Queries — SELECT, WHERE, ORDER BY, GROUP BY
```sql
-- Revenue and Profit by Category
SELECT 
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2)  AS Total_Profit
FROM sales
GROUP BY Category
ORDER BY Total_Revenue DESC;
```

### 2️⃣ Aggregate Functions — SUM, AVG, COUNT, MAX, MIN
```sql
-- Average Revenue Per Customer (ARPU)
SELECT 
    ROUND(AVG(customer_revenue), 2) AS Avg_Revenue_Per_Customer
FROM (
    SELECT Customer_Name, SUM(Revenue) AS customer_revenue
    FROM sales
    GROUP BY Customer_Name
) AS customer_totals;
```

### 3️⃣ HAVING Clause
```sql
-- Categories with Revenue above $20 Million
SELECT Category, ROUND(SUM(Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Category
HAVING Total_Revenue > 20000000
ORDER BY Total_Revenue DESC;
```

### 4️⃣ JOINS — INNER JOIN, LEFT JOIN
```sql
-- INNER JOIN: Sales vs Category Targets
SELECT 
    s.Category, c.Manager,
    ROUND(SUM(s.Revenue), 2) AS Total_Revenue,
    c.Target_Revenue
FROM sales s
INNER JOIN category_info c ON s.Category = c.Category
GROUP BY s.Category;
```

### 5️⃣ Subqueries
```sql
-- Products with Revenue above overall average
SELECT Product_Name, Category, ROUND(Revenue, 2) AS Revenue
FROM sales
WHERE Revenue > (SELECT AVG(Revenue) FROM sales)
ORDER BY Revenue DESC
LIMIT 15;
```

### 6️⃣ Views
```sql
-- Category Performance View
CREATE VIEW vw_category_performance AS
SELECT 
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit) * 100.0 / SUM(Revenue), 2) AS Profit_Margin_Pct
FROM sales
GROUP BY Category;
```

### 7️⃣ NULL Handling
```sql
-- Check for NULL values across all columns
SELECT 
    SUM(CASE WHEN Revenue IS NULL THEN 1 ELSE 0 END) AS Null_Revenue,
    SUM(CASE WHEN Profit  IS NULL THEN 1 ELSE 0 END) AS Null_Profit
FROM sales;
```

### 8️⃣ Indexes — Query Optimization
```sql
-- Create indexes for faster queries
CREATE INDEX idx_category ON sales(Category);
CREATE INDEX idx_region   ON sales(Region);
CREATE INDEX idx_revenue  ON sales(Revenue);
```

---

## 🔍 Key Business Insights from SQL Analysis

| Insight | Finding |
|---------|---------|
| 💰 Total Revenue | $142.4 Million across 200,000 orders |
| 🏆 Top Category | Electronics — $57.5M revenue |
| 📈 Best Margin | Accessories — 34% profit margin |
| 🌍 Top Region | East — $45.0M (31.6% of total) |
| 👤 Avg Revenue/Customer | $712 per order |
| 📦 Top Product | Tempur-Pedic Mattress — $9.06M |

---

## ▶️ How to Run

1. Download and install [DB Browser for SQLite](https://sqlitebrowser.org/dl/) (free)
2. Open `ecommerce.db` — the `sales` table is already loaded
3. Go to **Execute SQL** tab
4. Open and run `ecommerce_analysis.sql`

---

*Submitted as part of Elevate Labs Data Analyst Internship — Task 3*
