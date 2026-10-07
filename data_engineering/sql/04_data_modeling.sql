-- ==============================================================================
-- 04_data_modeling.sql
-- Description: Creates the presentation layer using a Dimensional Model 
--              (Star Schema) optimized for BI and Product Analytics.
-- ==============================================================================

CREATE SCHEMA IF NOT EXISTS analytics;

-- 1. Dimension: Customers (Slowly Changing Dimension Type 1 - simplified)
CREATE TABLE analytics.dim_customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM staging.stg_customers;

-- 2. Dimension: Products
CREATE TABLE analytics.dim_products AS
SELECT DISTINCT
    product_id,
    product_category
FROM staging.stg_products;

-- 3. Dimension: Date (Calendar Dimension)
CREATE TABLE analytics.dim_date AS
SELECT 
    CAST(TO_CHAR(d, 'YYYYMMDD') AS INT) AS date_key,
    d AS full_date,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(DOW FROM d) AS day_of_week,
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series(
    '2016-01-01'::DATE, 
    '2019-12-31'::DATE, 
    '1 day'::interval
) AS d;

-- 4. Fact Table: Order Items (Grain: One row per item in an order)
CREATE TABLE analytics.fact_order_items AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    CAST(TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD') AS INT) AS purchase_date_key,
    o.order_status,
    oi.price,
    oi.freight_value,
    oi.total_item_value,
    o.delivery_time_days
FROM staging.stg_order_items oi
INNER JOIN staging.stg_orders o ON oi.order_id = o.order_id;
