-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 08: OPERATIONS, LOGISTICS & CUSTOMER SATISFACTION
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 26: Order Fulfillment Lifecycle Milestones
-- Business Meaning:
-- Benchmarks the three key fulfillment phases:
-- Phase 1: Purchase to Approval (hours)
-- Phase 2: Approval to Carrier Handoff (days)
-- Phase 3: Carrier Handoff to Customer Delivery (days)
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) AS delivered_orders,
    ROUND(AVG(approval_time_hours), 2) AS avg_approval_time_hours,
    ROUND(AVG(carrier_delivery_days), 2) AS avg_carrier_handoff_days,
    ROUND(AVG(actual_delivery_days - carrier_delivery_days), 2) AS avg_in_transit_days,
    ROUND(AVG(actual_delivery_days), 2) AS avg_total_delivery_days,
    ROUND(AVG(estimated_delivery_days), 2) AS avg_estimated_delivery_days,
    ROUND(AVG(delivery_delay_days), 2) AS avg_days_ahead_of_schedule
FROM orders
WHERE order_status = 'delivered'
  AND actual_delivery_days >= 0 
  AND carrier_delivery_days >= 0;

-- --------------------------------------------------------------------
-- QUESTION 27: Delivery Logistics Performance by Customer State
-- Business Meaning:
-- Identifies states with highest fulfillment delays and longest delivery times.
-- --------------------------------------------------------------------
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_delivered_orders,
    ROUND(AVG(o.actual_delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(o.estimated_delivery_days), 1) AS avg_estimated_days,
    SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN o.is_late = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct,
    ROUND(AVG(o.order_freight), 2) AS avg_freight_paid,
    ROUND(AVG(o.review_score), 2) AS avg_customer_review
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_delivery_rate_pct DESC;

-- --------------------------------------------------------------------
-- QUESTION 28: Customer Satisfaction (Review Scores) vs Delivery Performance
-- Business Meaning:
-- Quantifies the relationship between on-time delivery vs late delivery
-- on customer review ratings (1-star vs 5-star shares).
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN o.is_late = 0 THEN '1. Delivered On-Time or Early'
        ELSE '2. Delivered Late (Past Estimated Date)'
    END AS delivery_punctuality,
    COUNT(o.order_id) AS total_delivered_orders,
    ROUND(AVG(o.actual_delivery_days), 1) AS avg_actual_delivery_days,
    ROUND(AVG(o.delivery_delay_days), 1) AS avg_delay_days,
    ROUND(AVG(o.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN o.review_score = 5 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS five_star_pct,
    ROUND(SUM(CASE WHEN o.review_score = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS one_star_pct
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- QUESTION 29: Delivery Delay Magnitude vs Average Review Score
-- Business Meaning:
-- Groups delayed orders into delay buckets to measure rating drop-off.
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN delivery_delay_days <= 0 THEN '0. On-Time / Early'
        WHEN delivery_delay_days <= 3 THEN '1. Slight Delay (1-3 days late)'
        WHEN delivery_delay_days <= 7 THEN '2. Moderate Delay (4-7 days late)'
        WHEN delivery_delay_days <= 14 THEN '3. Heavy Delay (8-14 days late)'
        ELSE '4. Severe Delay (15+ days late)'
    END AS delay_severity_bucket,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'), 2) AS pct_of_delivered,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN review_score = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS one_star_rating_pct
FROM orders
WHERE order_status = 'delivered' 
  AND review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- QUESTION 30: Cancellation Rate Trends Over Time
-- Business Meaning:
-- Evaluates platform order cancellations by month.
-- --------------------------------------------------------------------
SELECT 
    order_year_month,
    COUNT(order_id) AS total_orders_placed,
    SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
    ROUND(SUM(CASE WHEN order_status = 'canceled' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN order_status = 'canceled' THEN total_payment_value ELSE 0 END), 2) AS canceled_gmv_impact
FROM orders
WHERE order_year_month >= '2017-01' AND order_year_month <= '2018-08'
GROUP BY order_year_month
ORDER BY order_year_month;
