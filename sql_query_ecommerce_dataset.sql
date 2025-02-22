-- SQL E-Commerce Sales Analysis
CREATE DATABASE ecommerce_project;


-- Create TABLE
DROP TABLE IF EXISTS list_of_orders;
CREATE TABLE list_of_orders
            (
                order_id varchar(7) PRIMARY KEY,	
                order_date DATE,	 
                customer_name TEXT,	
                state text,
                city text
                );

DROP TABLE IF EXISTS order_details;
CREATE TABLE order_details
            (
                order_id varchar(7) PRIMARY KEY,	
                amount INT,	 
                profit INT,	
                quantity numeric,
                category text,
                sub_category text
                );
                
DROP TABLE IF EXISTS sales_target;
CREATE TABLE list_of_orders
            (
                month_of_order_date DATE,	
                category TEXT,	 
                target numeric
                );

-- Data Cleaning

-- There are no NULL values in all the tables but there is an error in list_of_orders table where in few rows of state 'Madhya Pradesh is listed as state of 'Delhi' city.
   
SELECT * FROM TableName
WHERE City = 'Delhi' AND State = 'Madhya Pradesh';
--

-- Correction
UPDATE list_of_orders
SET State = 'Delhi'
WHERE City = 'Delhi' AND State = 'Madhya Pradesh';


-- Data Exploration

-- How many orders we have?
SELECT COUNT(*) FROM list_of_orders;

-- How many uniuque customers we have?
SELECT COUNT(DISTINCT customer_name) AS unique_customers FROM list_of_orders;


-- DATA ANALYSIS & BUSINESS KEY PROBLEMS AND ANSWERS

-- My Analysis & Findings

-- 1.Find the total sales amount.
-- 2.Retrieve the total quantity sold per category.
-- 3.List the top 5 most frequently ordered sub-categories.
-- 4.Find the total profit earned per state.
-- 5.Get the top 3 cities with the highest total sales.
-- 6.Retrieve all orders where the profit margin is more than 20% of the sales amount.
-- 7.Identify the top-performing sub-category in each category.
-- 8.Rank states based on their total sales amount.
-- 9. Write a query to calculate the cumulative sales growth month by month.
-- 10.Find the difference between actual sales and sales target for each month and category where sales did not meet monthly target.


-- 1.Find the total sales amount.
SELECT 
    SUM(amount) AS total_sales
FROM
    order_details;


-- 2.Retrieve the total quantity sold per category.
SELECT 
    category, SUM(quantity) AS total_quantity
FROM
    order_details
GROUP BY 1;


-- 3.List the top 5 most frequently ordered sub-categories.
SELECT 
    sub_category, COUNT(order_id) AS total_orders
FROM
    order_details
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 4.Find the total profit earned per state.
SELECT 
    l.state, SUM(o.profit) AS total_profit
FROM
    list_of_orders l
        JOIN
    order_details o ON o.order_id = l.order_id
GROUP BY 1;


-- 5.Get the top 3 cities with the highest total sales.
SELECT 
    l.city, SUM(amount) AS total_sales
FROM
    list_of_orders l
        JOIN
    order_details d ON d.order_id = l.order_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- 6.Retrieve all orders where the profit margin is more than 20% of the sales amount.
SELECT 
    *, ROUND((profit / amount) * 100, 2) profit_margin_pct
FROM
    order_details
WHERE
    (profit / amount) > 0.2;
    
    
-- 7.Identify the top-performing sub-category in each category.
with top_sub_category as (
select category,
sub_category,
sum(amount) as total_sales,
rank()over(partition by category order by sum(amount) desc) as rnk
from order_details
group by 1,2
)

select category,
sub_category,
total_sales 
from top_sub_category
where rnk = 1;


-- 8.Rank states based on their total sales amount.
select l.state,
sum(o.amount) as total_sales,
rank()over(order by sum(amount) desc) as state_rank
from list_of_orders l
join order_details o on o.order_id = l.order_id
group by 1;


-- 9. Write a query to calculate the cumulative sales growth month by month.
select extract(year from l.order_date),
extract(month from l.order_date),
sum(amount) as monthly_sales,
sum(sum(amount))over(order by extract(year from l.order_date), extract(month from l.order_date)) as cum_sum
from list_of_orders l
join order_details o on o.order_id = l.order_id
group by 1,2;


-- 11.Find the difference between actual sales and sales target for each month and category where sales did not meet monthly target.
with sales_target as (
select o.category,
extract(year from l.order_date) as year,
extract(month from l.order_date) as month,
sum(o.amount)as total_sales,
t.target
from list_of_orders l 
join order_details o on o.order_id = l.order_id
join sales_target t on o.category = t.category and
extract(year from l.order_date) = extract(year from t.month_of_order_date) and
extract(month from l.order_date) = extract(month from t.month_of_order_date)
group by 1,2,3,5
)

SELECT category,
year,
month,
total_sales,
target,
total_sales - target as difference
from sales_target


-- END OF PROJECT
    
















