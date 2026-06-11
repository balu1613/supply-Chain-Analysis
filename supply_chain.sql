CREATE TABLE supply_chain (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order FLOAT,
    sales_per_customer FLOAT,
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    customer_city VARCHAR(100),
    customer_country VARCHAR(100),
    customer_email VARCHAR(150),
    customer_fname VARCHAR(100),
    customer_id INT,
    customer_lname VARCHAR(100),
    customer_password VARCHAR(100),
    customer_segment VARCHAR(50),
    customer_state VARCHAR(100),
    customer_street VARCHAR(150),
    customer_zipcode VARCHAR(20),
    department_id INT,
    department_name VARCHAR(100),
    latitude FLOAT,
    longitude FLOAT,
    market VARCHAR(50),
    order_city VARCHAR(100),
    order_country VARCHAR(100),
    order_customer_id INT,
    order_date TIMESTAMP,
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount FLOAT,
    order_item_discount_rate FLOAT,
    order_item_id INT,
    order_item_product_price FLOAT,
    order_item_profit_ratio FLOAT,
    order_item_quantity INT,
    sales FLOAT,
    order_item_total FLOAT,
    order_profit_per_order FLOAT,
    order_region VARCHAR(100),
    order_state VARCHAR(100),
    order_status VARCHAR(50),
    order_zipcode VARCHAR(20),
    product_card_id INT,
    product_category_id INT,
    product_description TEXT,
    product_image TEXT,
    product_name VARCHAR(150),
    product_price FLOAT,
    product_status INT,
    shipping_date TIMESTAMP,
    shipping_mode VARCHAR(50)
);
select count(*) from supply_chain;
SELECT * FROM supply_chain LIMIT 5;

--How many total orders do we have, and how many of them were delivered late?
--What percentage of our orders have a late delivery risk
SELECT
	COUNT(order_id) as Total_orders,
	SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS Late_orders,
	ROUND(
        SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2
    ) AS late_delivery_percentage
FROM supply_chain;

SELECT 
	order_region,
	sum(late_delivery_risk) as late_delivery_rate
FROM supply_chain
GROUP BY order_region
ORDER BY late_delivery_rate DESC;
--2 Which regions have the highest late delivery rates? Rank worst to best.
SELECT 
	order_country,
	count(*) as total_orders,
	sum(late_delivery_risk) as total_late_deliveries,
	ROUND(SUM(late_delivery_risk)*100.0/count(*),2) as late_delivery_rate,
	DENSE_RANK() OVER(
					ORDER BY SUM(late_delivery_risk)*100/count(*) DESC
	) as region_
FROM supply_chain
group by order_country;

--3 . Which shipping mode has the highest late delivery risk? Compare all shipping modes
select distinct(shipping_mode)
from supply_chain;

SELECT 
	shipping_mode,
	count(*) as total_orders,
	sum(late_delivery_risk) as total_late_deliveries,
	ROUND(SUM(late_delivery_risk)*100.0/count(*)) as late_delivery_rate,
	DENSE_RANK() OVER(ORDER BY ROUND(SUM(late_delivery_risk)*100.0/count(*)) DESC) as shipping_rank
FROM supply_chain
GROUP BY shipping_mode;
--4  What is the average number of days late we are shipping compared to scheduled? Which department is worst?	
SELECT 
	department_name,
	AVG(days_for_shipping_real - days_for_shipment_scheduled) as avg_late_days
FROM supply_chain
WHERE days_for_shipping_real > days_for_shipment_scheduled
GROUP BY department_name
ORDER BY  avg_late_days DESC;
	

--5 Which product categories are generating the most profit and which are bleeding money? Show top 5 profitable and bottom 5.
SELECT 
	category_name,
	ROUND(sum(order_profit_per_order)) as total_profit
FROM supply_chain
GROUP BY category_name
ORDER BY total_profit DESC
limit 5;
SELECT 
	category_name,
	ROUND(sum(order_profit_per_order)) as total_profit
FROM supply_chain
GROUP BY category_name
ORDER BY total_profit 
limit 5;
--6 Who are our top 10 customers by total sales? Are any of them high late delivery risk?
SELECT
	customer_id,
	SUM(sales) as total_sales,
	sum(late_delivery_risk) as total_late_deliveries,
	ROUND(SUM(late_delivery_risk)*100.0/count(*)) as late_delivery_rate,
	(SELECT ROUND(SUM(late_delivery_risk)*100.0/count(*)) as late_delivery FROM supply_chain) as company_avg
FROM supply_chain
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;
--7 What is the month-over-month trend in total orders and late deliveries? Is it getting worse or better over time?
SELECT 
	td,
	current_month_orders,
	previous_month_orders,
	ROUND((current_month_orders - previous_month_orders)*100/previous_month_orders,2) as mom,
	current_month_late_deliveries,
	previous_month_late_deliveries,
	ROUND((current_month_late_deliveries-previous_month_late_deliveries)*100/previous_month_late_deliveries,2) as MOM
FROM (
SELECT
	DATE_TRUNC('month', order_date) as td,
	count(*) as current_month_orders,
	LAG(count(*)) OVER(ORDER BY DATE_TRUNC('month', order_date) ) as previous_month_orders,
	SUM(late_delivery_risk) as current_month_late_deliveries,
	LAG(SUM(late_delivery_risk)) OVER(ORDER BY  DATE_TRUNC('month', order_date) ) as previous_month_late_deliveries
FROM supply_chain
GROUP BY DATE_TRUNC('month', order_date)
)
ORDER BY td;

--8  Which markets have the highest average benefit per order? Which are least profitable?
SELECT 
	order_region,
	ROUND(AVG(benefit_per_order)) as avg_profit,
	ROUND(SUM(benefit_per_order)) as total_profit,
	DENSE_RANK() OVER(ORDER BY AVG(benefit_per_order)DESC) as avg_rank,
	DENSE_RANK() OVER(ORDER BY SUM(benefit_per_order)DESC) as total_profit_rank
FROM supply_chain
GROUP BY order_region;
--9 What percentage of orders are in each order status — COMPLETE, PENDING, CANCELED, SUSPECTED_FRAUD etc? What does this tell us?
SELECT 
	order_status,
	count(*) as status_orders,
	count(*)*100/(select count(*) from supply_chain) as status_perct
FROM supply_chain
GROUP BY order_status;

--10 Find customers who placed more than 5 orders but have a late delivery rate above 70%. 
--These are high-value customers we are consistently failing.
SELECT
    customer_id,
    customer_fname,
    customer_lname,
    COUNT(*) AS total_orders,
    SUM(late_delivery_risk) AS late_orders,
    ROUND(SUM(late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_rate_percent
FROM supply_chain
GROUP BY customer_id, customer_fname, customer_lname
HAVING COUNT(*) > 5
AND ROUND(SUM(late_delivery_risk) * 100.0 / COUNT(*), 2) > 70
ORDER BY late_rate_percent DESC;

--11 What is the relationship between discount rate and profit ratio? Are high discounts killing our margins?
SELECT
    CASE
        WHEN order_item_discount_rate = 0 THEN 'No Discount'
        WHEN order_item_discount_rate <= 0.1 THEN 'Low (0-10%)'
        WHEN order_item_discount_rate <= 0.2 THEN 'Medium (10-20%)'
        WHEN order_item_discount_rate <= 0.3 THEN 'High (20-30%)'
        ELSE 'Very High (30%+)'
    END AS discount_bucket,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_item_discount_rate)::numeric * 100, 2) AS avg_discount_percent,
    ROUND(AVG(order_item_profit_ratio)::numeric * 100, 2) AS avg_profit_ratio_percent
FROM supply_chain
GROUP BY discount_bucket
ORDER BY avg_discount_percent ASC;





