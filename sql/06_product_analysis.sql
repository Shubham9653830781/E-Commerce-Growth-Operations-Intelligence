-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 06: PRODUCT & CATEGORY INTELLIGENCE
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 16: Top 10 Product Categories by Gross Merchandise Value (GMV)
-- Business Meaning:
-- Ranks categories by revenue, order item volume, and calculates their
-- percentage contribution to total marketplace GMV.
-- --------------------------------------------------------------------
SELECT 
    p.category_name_english AS product_category,
    COUNT(oi.order_item_id) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS distinct_orders,
    ROUND(SUM(oi.price), 2) AS category_gmv,
    ROUND(SUM(oi.price) * 100.0 / (SELECT SUM(price) FROM order_items), 2) AS gmv_share_pct,
    ROUND(SUM(oi.freight_value), 2) AS category_freight,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name_english
ORDER BY category_gmv DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 17: Top 10 Individual Products by Lifetime GMV
-- Business Meaning:
-- Identifies the single highest revenue-generating SKUs on the platform.
-- --------------------------------------------------------------------
SELECT 
    p.product_id,
    p.category_name_english AS category,
    COUNT(oi.order_item_id) AS units_sold,
    ROUND(SUM(oi.price), 2) AS total_product_sales,
    ROUND(AVG(oi.price), 2) AS avg_selling_price,
    ROUND(AVG(o.review_score), 2) AS product_avg_review
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.category_name_english
ORDER BY total_product_sales DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 18: Top 10 Categories by Customer Satisfaction (Highest Review Scores)
-- Business Meaning:
-- Identifies product lines with exceptional customer satisfaction (min 100 orders).
-- --------------------------------------------------------------------
SELECT 
    p.category_name_english AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN r.review_score = 5 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS five_star_pct,
    ROUND(SUM(CASE WHEN r.review_score = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS one_star_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.category_name_english
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_review_score DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 19: Categories with Quality & Customer Satisfaction Issues
-- Business Meaning:
-- Flags categories with lowest review scores and high negative sentiment.
-- --------------------------------------------------------------------
SELECT 
    p.category_name_english AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN r.review_score = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS one_star_pct,
    ROUND(SUM(CASE WHEN r.review_score = 5 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS five_star_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.category_name_english
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY avg_review_score ASC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 20: Product Physical Weight & Volume vs Freight Cost Burden
-- Business Meaning:
-- Measures how product bulkiness impacts freight value and delivery delays.
-- --------------------------------------------------------------------
SELECT 
    p.category_name_english AS product_category,
    COUNT(oi.order_item_id) AS items_sold,
    ROUND(AVG(p.product_weight_kg), 2) AS avg_weight_kg,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.freight_value) * 100.0 / NULLIF(AVG(oi.price), 0), 2) AS freight_to_price_ratio_pct,
    ROUND(AVG(o.actual_delivery_days), 1) AS avg_delivery_days
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category_name_english
HAVING COUNT(oi.order_item_id) >= 200
ORDER BY avg_weight_kg DESC
LIMIT 10;
