-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 05: RFM (RECENCY, FREQUENCY, MONETARY) SEGMENTATION
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 11: RFM Segment Distribution & Revenue Contribution
-- Business Meaning:
-- Benchmarks the customer base across the 8 behavioral RFM segments:
-- Champions, Loyal Customers, Recent New Buyers, Promising Regulars,
-- At Risk, Cant Lose Them, Hibernating High Spenders, Lost / Inactive.
-- --------------------------------------------------------------------
SELECT 
    rfm_segment,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(COUNT(customer_unique_id) * 100.0 / (SELECT COUNT(*) FROM customer_rfm), 2) AS customer_share_pct,
    ROUND(SUM(monetary), 2) AS segment_gmv,
    ROUND(SUM(monetary) * 100.0 / (SELECT SUM(monetary) FROM customer_rfm), 2) AS gmv_contribution_pct,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_spend_per_customer
FROM customer_rfm
GROUP BY rfm_segment
ORDER BY segment_gmv DESC;

-- --------------------------------------------------------------------
-- QUESTION 12: VIP Champions & Loyal Customers Deep Dive
-- Business Meaning:
-- Analyzes highest-value buyers with repeat purchases and recent activity.
-- --------------------------------------------------------------------
SELECT 
    customer_unique_id,
    customer_city,
    customer_state,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS total_gmv,
    ROUND(total_spend_with_freight, 2) AS total_with_freight,
    cohort_month,
    rfm_segment
FROM customer_rfm
WHERE rfm_segment IN ('Champions', 'Loyal Customers')
ORDER BY monetary DESC
LIMIT 15;

-- --------------------------------------------------------------------
-- QUESTION 13: At-Risk & High-Value Hibernating Customers ("Churn Risk")
-- Business Meaning:
-- Identifies formerly high-spending buyers who haven't ordered recently.
-- --------------------------------------------------------------------
SELECT 
    customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS total_historical_spend,
    rfm_segment
FROM customer_rfm
WHERE rfm_segment IN ('At Risk', 'Cant Lose Them', 'Hibernating High Spenders')
ORDER BY monetary DESC
LIMIT 15;

-- --------------------------------------------------------------------
-- QUESTION 14: Recency Score vs Monetary Score Matrix
-- Business Meaning:
-- Evaluates relationship between customer purchase freshness and spend level.
-- --------------------------------------------------------------------
SELECT 
    r_score,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(AVG(recency_days), 1) AS avg_recency,
    ROUND(AVG(monetary), 2) AS avg_monetary_spend,
    SUM(CASE WHEN m_score = 5 THEN 1 ELSE 0 END) AS top_tier_monetary_customers,
    SUM(CASE WHEN m_score = 1 THEN 1 ELSE 0 END) AS lowest_tier_monetary_customers
FROM customer_rfm
GROUP BY r_score
ORDER BY r_score DESC;

-- --------------------------------------------------------------------
-- QUESTION 15: Repeat Customer State Distribution
-- Business Meaning:
-- Identifies which states produce the highest density of repeat buyers.
-- --------------------------------------------------------------------
SELECT 
    customer_state,
    COUNT(customer_unique_id) AS total_customers,
    SUM(CASE WHEN frequency > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(SUM(CASE WHEN frequency > 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS repeat_buyer_pct,
    ROUND(SUM(monetary), 2) AS state_gmv
FROM customer_rfm
GROUP BY customer_state
HAVING COUNT(*) >= 500
ORDER BY repeat_buyer_pct DESC;
