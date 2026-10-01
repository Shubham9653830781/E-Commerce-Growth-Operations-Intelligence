-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 07: SELLER PERFORMANCE & OPERATIONAL INTEGRITY
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 21: Top 10 Marketplace Sellers by Lifetime GMV
-- Business Meaning:
-- Identifies top merchant partners, their location, items sold, and reviews.
-- --------------------------------------------------------------------
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(oi.order_item_id) AS total_items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_seller_gmv,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_generated,
    ROUND(AVG(r.review_score), 2) AS avg_seller_review
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_seller_gmv DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 22: Seller Volume Tiers & Revenue Concentration
-- Business Meaning:
-- Categorizes sellers into volume tiers: 1-10 items, 11-50, 51-200, 201-500, 500+ items.
-- --------------------------------------------------------------------
WITH seller_volumes AS (
    SELECT 
        seller_id,
        COUNT(order_item_id) AS items_sold,
        SUM(price) AS seller_gmv
    FROM order_items
    GROUP BY seller_id
)
SELECT 
    CASE 
        WHEN items_sold <= 10 THEN '1. Boutique / Small (1-10 items)'
        WHEN items_sold <= 50 THEN '2. Emerging Merchant (11-50 items)'
        WHEN items_sold <= 200 THEN '3. Established Seller (51-200 items)'
        WHEN items_sold <= 500 THEN '4. High-Volume Seller (201-500 items)'
        ELSE '5. Enterprise Anchor (500+ items)'
    END AS seller_tier,
    COUNT(seller_id) AS seller_count,
    ROUND(COUNT(seller_id) * 100.0 / (SELECT COUNT(*) FROM seller_volumes), 2) AS seller_share_pct,
    ROUND(SUM(seller_gmv), 2) AS aggregate_tier_gmv,
    ROUND(SUM(seller_gmv) * 100.0 / (SELECT SUM(seller_gmv) FROM seller_volumes), 2) AS gmv_share_pct,
    ROUND(AVG(seller_gmv), 2) AS avg_gmv_per_seller
FROM seller_volumes
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- QUESTION 23: Sellers with Operational Delivery & Satisfaction Risk
-- Business Meaning:
-- Flags sellers with high volume (>= 50 items) who exhibit elevated
-- late delivery rates (> 15%) or substandard average review scores (< 3.8).
-- --------------------------------------------------------------------
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS seller_gmv,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN o.is_late = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(DISTINCT oi.order_id), 2) AS late_delivery_rate_pct,
    ROUND(AVG(o.actual_delivery_days), 1) AS avg_delivery_days
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50 
   AND (AVG(r.review_score) < 3.80 OR late_delivery_rate_pct > 15.0)
ORDER BY late_delivery_rate_pct DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 24: Top 10 Operational Excellence Sellers
-- Business Meaning:
-- Identifies top-tier sellers with high volume (>= 100 orders),
-- high review scores (>= 4.2), and low late delivery rates (< 5%).
-- --------------------------------------------------------------------
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS seller_gmv,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN o.is_late = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(DISTINCT oi.order_id), 2) AS late_delivery_rate_pct,
    ROUND(AVG(o.actual_delivery_days), 1) AS avg_delivery_days
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 100 
   AND AVG(r.review_score) >= 4.20 
   AND late_delivery_rate_pct < 5.0
ORDER BY seller_gmv DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 25: Seller Geographic Distribution by State
-- Business Meaning:
-- Tracks seller origination hubs and cross-border geographic presence.
-- --------------------------------------------------------------------
SELECT 
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS unique_sellers,
    COUNT(oi.order_item_id) AS total_items_shipped,
    ROUND(SUM(oi.price), 2) AS total_origin_gmv,
    ROUND(SUM(oi.price) * 100.0 / (SELECT SUM(price) FROM order_items), 2) AS gmv_share_pct
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_origin_gmv DESC
LIMIT 10;
