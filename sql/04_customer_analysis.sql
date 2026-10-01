-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 04: CUSTOMER ANALYTICS & LIFETIME VALUE
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 6: Unique Customer Base & True Repeat Customer Rate
-- Business Meaning:
-- Computes the true repeat purchase rate using permanent customer_unique_id
-- rather than transient session customer_id.
-- --------------------------------------------------------------------
WITH customer_order_counts AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.order_subtotal) AS lifetime_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled')
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(customer_unique_id) AS total_active_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(SUM(CASE WHEN total_orders > 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS repeat_customer_rate_pct,
    ROUND(AVG(total_orders), 3) AS avg_orders_per_customer,
    ROUND(AVG(lifetime_spend), 2) AS avg_lifetime_spend_per_customer
FROM customer_order_counts;

-- --------------------------------------------------------------------
-- QUESTION 7: Customer Order Frequency Distribution
-- Business Meaning:
-- Groups customers into frequency cohorts to evaluate retention drop-off.
-- --------------------------------------------------------------------
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(o.order_subtotal) AS total_gmv
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled')
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN '1. One-Time Buyer (1 Order)'
        WHEN order_count = 2 THEN '2. Repeat Buyer (2 Orders)'
        WHEN order_count = 3 THEN '3. Frequent Buyer (3 Orders)'
        ELSE '4. Power Buyer (4+ Orders)'
    END AS buyer_frequency_tier,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) * 100.0 / (SELECT COUNT(*) FROM customer_orders), 2) AS customer_share_pct,
    ROUND(SUM(total_gmv), 2) AS aggregate_gmv,
    ROUND(SUM(total_gmv) * 100.0 / (SELECT SUM(total_gmv) FROM customer_orders), 2) AS gmv_contribution_pct,
    ROUND(AVG(total_gmv), 2) AS avg_spend_per_customer
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- QUESTION 8: Top 10 High-Value Customers by Historical GMV
-- Business Meaning:
-- Identifies VIP accounts, their order counts, and primary geographic state.
-- --------------------------------------------------------------------
SELECT 
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS orders_placed,
    SUM(o.total_items) AS items_purchased,
    ROUND(SUM(o.order_subtotal), 2) AS total_product_spend,
    ROUND(SUM(o.order_freight), 2) AS total_freight_paid,
    ROUND(SUM(o.order_total_value), 2) AS total_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status NOT IN ('canceled')
GROUP BY c.customer_unique_id, c.customer_state, c.customer_city
ORDER BY total_product_spend DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- QUESTION 9: Geographic Customer Distribution by State
-- Business Meaning:
-- Measures customer demand, revenue, and AOV across all 27 Brazilian states.
-- --------------------------------------------------------------------
SELECT 
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_subtotal), 2) AS state_gmv,
    ROUND(SUM(o.order_subtotal) * 100.0 / (SELECT SUM(order_subtotal) FROM orders), 2) AS gmv_share_pct,
    ROUND(SUM(o.order_freight), 2) AS state_freight,
    ROUND(SUM(o.order_subtotal) / COUNT(DISTINCT o.order_id), 2) AS state_aov,
    ROUND(AVG(o.review_score), 2) AS avg_customer_review
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY state_gmv DESC;

-- --------------------------------------------------------------------
-- QUESTION 10: Top 10 Metro Cities by Customer Demand & Revenue
-- Business Meaning:
-- Identifies prime urban clusters for localized marketing and warehousing.
-- --------------------------------------------------------------------
SELECT 
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_subtotal), 2) AS city_gmv,
    ROUND(SUM(o.order_freight), 2) AS city_freight,
    ROUND(SUM(o.order_subtotal) / COUNT(DISTINCT o.order_id), 2) AS city_aov
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city, c.customer_state
ORDER BY city_gmv DESC
LIMIT 10;
