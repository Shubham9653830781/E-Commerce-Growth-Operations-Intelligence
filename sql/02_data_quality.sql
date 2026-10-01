-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 02: DATA QUALITY & INTEGRITY VALIDATION
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- CHECK 1: Table Row Count Verification Across Entities
-- Expected Result: Matches official Olist raw file counts exactly
-- --------------------------------------------------------------------
SELECT 'orders' AS table_name, COUNT(*) AS total_rows FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customer_rfm', COUNT(*) FROM customer_rfm;

-- --------------------------------------------------------------------
-- CHECK 2: Null Value Audit on Core Order Attributes
-- Expected Result: Zero nulls on critical operational fields
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_ids,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_statuses,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamps,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_dates
FROM orders;

-- --------------------------------------------------------------------
-- CHECK 3: Primary Key Uniqueness Across Core Entities
-- Expected Result: Total rows minus distinct PKs = 0 duplicates
-- --------------------------------------------------------------------
SELECT 
    'orders' AS entity,
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_pks,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_pks
FROM orders
UNION ALL
SELECT 
    'customers',
    COUNT(*),
    COUNT(DISTINCT customer_id),
    COUNT(*) - COUNT(DISTINCT customer_id)
FROM customers
UNION ALL
SELECT 
    'sellers',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    COUNT(*) - COUNT(DISTINCT seller_id)
FROM sellers
UNION ALL
SELECT 
    'products',
    COUNT(*),
    COUNT(DISTINCT product_id),
    COUNT(*) - COUNT(DISTINCT product_id)
FROM products;

-- --------------------------------------------------------------------
-- CHECK 4: Referential Integrity Check Between Tables
-- Expected Result: 0 orphaned child records
-- --------------------------------------------------------------------
SELECT 
    'order_items without order' AS check_type,
    COUNT(*) AS orphan_count
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 
    'order_items without product',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 
    'order_items without seller',
    COUNT(*)
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 
    'orders without customer',
    COUNT(*)
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- --------------------------------------------------------------------
-- CHECK 5: Delivery Date Chronological Consistency Check
-- Expected Result: Delivered customer date must never precede purchase date
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN order_delivered_customer_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS delivery_before_purchase_anomalies
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- --------------------------------------------------------------------
-- CHECK 6: Numerical Domain & Currency Sanity
-- Expected Result: Price strictly positive and freight and payments non-negative
-- --------------------------------------------------------------------
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price_count,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight_count
FROM order_items;
