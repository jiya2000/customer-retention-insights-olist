-- ==============================================================================
-- 05_product_metrics.sql
-- Description: Example analytics queries answering product-centric questions.
--              Includes CTEs, window functions, and cohorts.
-- ==============================================================================

-- 1. Monthly Active Users (MAU) Equivalent (Monthly Purchasing Customers)
SELECT 
    d.year,
    d.month,
    COUNT(DISTINCT f.customer_id) AS monthly_active_purchasers,
    SUM(f.total_item_value) AS monthly_gmv
FROM analytics.fact_order_items f
JOIN analytics.dim_date d ON f.purchase_date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- 2. Customer Cohort Retention (Month 0 to Month N Retention)
WITH customer_first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(DATE_TRUNC('month', d.full_date)) AS first_purchase_month
    FROM analytics.fact_order_items f
    JOIN analytics.dim_customers c ON f.customer_id = c.customer_id
    JOIN analytics.dim_date d ON f.purchase_date_key = d.date_key
    GROUP BY c.customer_unique_id
),
cohort_purchases AS (
    SELECT 
        cfp.customer_unique_id,
        cfp.first_purchase_month,
        DATE_TRUNC('month', d.full_date) AS purchase_month,
        EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', d.full_date), cfp.first_purchase_month)) * 12 + 
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', d.full_date), cfp.first_purchase_month)) AS month_number
    FROM analytics.fact_order_items f
    JOIN analytics.dim_customers c ON f.customer_id = c.customer_id
    JOIN analytics.dim_date d ON f.purchase_date_key = d.date_key
    JOIN customer_first_purchase cfp ON c.customer_unique_id = cfp.customer_unique_id
)
SELECT 
    first_purchase_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS retained_customers
FROM cohort_purchases
GROUP BY first_purchase_month, month_number
ORDER BY first_purchase_month, month_number;

-- 3. Repeat Purchase Rate using Window Functions
WITH customer_order_ranks AS (
    SELECT 
        c.customer_unique_id,
        f.order_id,
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY f.purchase_date_key) AS order_sequence_num
    FROM analytics.fact_order_items f
    JOIN analytics.dim_customers c ON f.customer_id = c.customer_id
    GROUP BY c.customer_unique_id, f.order_id, f.purchase_date_key
)
SELECT 
    COUNT(DISTINCT CASE WHEN order_sequence_num > 1 THEN customer_unique_id END) * 100.0 / 
    COUNT(DISTINCT customer_unique_id) AS repeat_purchase_rate_percentage
FROM customer_order_ranks;

-- 4. Running Total of Revenue by Category
WITH monthly_category_revenue AS (
    SELECT 
        d.year,
        d.month,
        p.product_category,
        SUM(f.total_item_value) AS monthly_revenue
    FROM analytics.fact_order_items f
    JOIN analytics.dim_products p ON f.product_id = p.product_id
    JOIN analytics.dim_date d ON f.purchase_date_key = d.date_key
    GROUP BY d.year, d.month, p.product_category
)
SELECT 
    year,
    month,
    product_category,
    monthly_revenue,
    SUM(monthly_revenue) OVER (PARTITION BY product_category ORDER BY year, month 
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue
FROM monthly_category_revenue
ORDER BY product_category, year, month;
