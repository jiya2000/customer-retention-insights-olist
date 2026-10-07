-- ==============================================================================
-- 02_data_quality_checks_raw.sql
-- Description: Queries designed to catch nulls, duplicates, orphaned keys, 
--              and structural issues in the raw data layer before staging.
-- ==============================================================================

-- 1. Check for Duplicate Primary Keys in Orders
SELECT order_id, COUNT(*)
FROM raw.olist_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. Check for Nulls in Critical Fields (Purchase Timestamp)
SELECT COUNT(*) AS null_purchase_timestamps
FROM raw.olist_orders
WHERE order_purchase_timestamp IS NULL;

-- 3. Orphaned Keys: Orders without a valid Customer
SELECT COUNT(*) AS orphaned_orders
FROM raw.olist_orders o
LEFT JOIN raw.olist_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 4. Orphaned Keys: Order Items without a valid Product
SELECT COUNT(*) AS items_without_products
FROM raw.olist_order_items oi
LEFT JOIN raw.olist_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 5. Negative or Zero Values in Payments
SELECT COUNT(*) AS invalid_payments
FROM raw.olist_order_payments
WHERE payment_value <= 0;

-- 6. Check Delivery Consistency (Delivered before purchased)
SELECT COUNT(*) AS illogical_delivery_dates
FROM raw.olist_orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 7. Missing Product Categories
SELECT COUNT(*) AS missing_categories
FROM raw.olist_products
WHERE product_category_name IS NULL OR product_category_name = '';
