-- ==============================================================================
-- 03_cleaning_and_staging.sql
-- Description: Transforms the raw layer into a cleaned staging layer.
--              Handles nulls, standardizes categories, removes invalid rows.
-- ==============================================================================

CREATE SCHEMA IF NOT EXISTS staging;

-- 1. Cleaned Customers
CREATE TABLE staging.stg_customers AS
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    UPPER(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.olist_customers;

-- 2. Cleaned Orders (filtering out illogical dates and missing purchase times)
CREATE TABLE staging.stg_orders AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    -- Calculate delivery time in days
    EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400 AS delivery_time_days
FROM raw.olist_orders
WHERE order_purchase_timestamp IS NOT NULL
  AND (order_delivered_customer_date >= order_purchase_timestamp OR order_delivered_customer_date IS NULL);

-- 3. Cleaned Products (Handling missing categories)
CREATE TABLE staging.stg_products AS
SELECT 
    product_id,
    COALESCE(product_category_name, 'Unknown') AS product_category,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.olist_products;

-- 4. Cleaned Order Items
CREATE TABLE staging.stg_order_items AS
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    price,
    freight_value,
    (price + freight_value) AS total_item_value
FROM raw.olist_order_items;

-- 5. Cleaned Payments (Removing invalid payments)
CREATE TABLE staging.stg_order_payments AS
SELECT 
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM raw.olist_order_payments
WHERE payment_value > 0;
