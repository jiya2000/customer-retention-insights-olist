-- ==============================================================================
-- 06_performance_optimization.sql
-- Description: Example of physical data modeling tuning (Indexing & Partitioning)
-- ==============================================================================

-- 1. Indexing for Fast Lookups
-- Scenario: The BI tool frequently filters by product category and date.
-- Before Index: Sequential scan on fact table.
-- After Index: Bitmap index scan.

CREATE INDEX idx_fact_date_product 
ON analytics.fact_order_items (purchase_date_key, product_id);

CREATE INDEX idx_dim_customer_unique 
ON analytics.dim_customers (customer_unique_id);

-- 2. Partitioning Example (Conceptual for PostgreSQL)
-- If we were recreating the fact table to handle billions of rows, 
-- we would partition it by date (e.g., Monthly).

/*
CREATE TABLE analytics.fact_order_items_partitioned (
    order_id VARCHAR(50),
    order_item_id INT,
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    purchase_date_key INT,
    order_status VARCHAR(20),
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    total_item_value DECIMAL(10, 2),
    delivery_time_days FLOAT
) PARTITION BY RANGE (purchase_date_key);

CREATE TABLE fact_order_items_201701 PARTITION OF analytics.fact_order_items_partitioned
    FOR VALUES FROM (20170101) TO (20170201);
    
CREATE TABLE fact_order_items_201702 PARTITION OF analytics.fact_order_items_partitioned
    FOR VALUES FROM (20170201) TO (20170301);
*/
