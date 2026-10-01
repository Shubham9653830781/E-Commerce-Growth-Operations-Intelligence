-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 09: ADVANCED SQL ANALYTICAL ENGINEERING
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Techniques: CTEs, Window Functions (DENSE_RANK, ROW_NUMBER, LAG, LEAD),
--             Running Totals, Cohort Retention Matrix, Moving Averages
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 31: Month-over-Month (MoM) Order & GMV Growth using LAG()
-- Business Meaning:
-- Computes the monthly revenue velocity and percentage growth rates.
-- --------------------------------------------------------------------
WITH monthly_data AS (
    SELECT 
        order_year_month,
        COUNT(order_id) AS current_orders,
        ROUND(SUM(order_subtotal), 2) AS current_gmv
    FROM orders
    WHERE order_year_month >= '2017-01' AND order_year_month <= '2018-08'
    GROUP BY order_year_month
)
SELECT 
    order_year_month,
    current_orders,
    LAG(current_orders, 1) OVER (ORDER BY order_year_month) AS prev_orders,
    ROUND((current_orders - LAG(current_orders, 1) OVER (ORDER BY order_year_month)) * 100.0 / 
          LAG(current_orders, 1) OVER (ORDER BY order_year_month), 2) AS mom_order_growth_pct,
    current_gmv,
    LAG(current_gmv, 1) OVER (ORDER BY order_year_month) AS prev_gmv,
    ROUND((current_gmv - LAG(current_gmv, 1) OVER (ORDER BY order_year_month)) * 100.0 / 
          LAG(current_gmv, 1) OVER (ORDER BY order_year_month), 2) AS mom_gmv_growth_pct
FROM monthly_data;

-- --------------------------------------------------------------------
-- QUESTION 32: Cumulative Running Platform GMV using SUM() OVER ()
-- Business Meaning:
-- Tracks enterprise cumulative GMV expansion across the timeline.
-- --------------------------------------------------------------------
WITH monthly_sales AS (
    SELECT 
        order_year_month,
        ROUND(SUM(order_subtotal), 2) AS monthly_gmv
    FROM orders
    WHERE order_year_month >= '2017-01' AND order_year_month <= '2018-08'
    GROUP BY order_year_month
)
SELECT 
    order_year_month,
    monthly_gmv,
    ROUND(SUM(monthly_gmv) OVER (
        ORDER BY order_year_month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS cumulative_running_gmv
FROM monthly_sales;

-- --------------------------------------------------------------------
-- QUESTION 33: Top 3 Bestselling Products per Category using DENSE_RANK()
-- Business Meaning:
-- Identifies top 3 revenue-generating products within each merchandise category.
-- --------------------------------------------------------------------
WITH category_product_sales AS (
    SELECT 
        p.category_name_english AS category,
        p.product_id,
        COUNT(oi.order_item_id) AS units_sold,
        ROUND(SUM(oi.price), 2) AS product_gmv,
        DENSE_RANK() OVER (
            PARTITION BY p.category_name_english 
            ORDER BY SUM(oi.price) DESC
        ) AS rank_in_category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE p.category_name_english IS NOT NULL AND p.category_name_english != 'unclassified'
    GROUP BY p.category_name_english, p.product_id
)
SELECT 
    category,
    rank_in_category,
    product_id,
    units_sold,
    product_gmv
FROM category_product_sales
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category
LIMIT 30;

-- --------------------------------------------------------------------
-- QUESTION 34: Customer Pareto Revenue Concentration (80/20 Rule)
-- Business Meaning:
-- Calculates what percentage of total marketplace GMV is driven by the
-- top 20% of customers using window functions.
-- --------------------------------------------------------------------
WITH customer_totals AS (
    SELECT 
        customer_unique_id,
        monetary AS cust_spend
    FROM customer_rfm
),
ranked_customers AS (
    SELECT 
        customer_unique_id,
        cust_spend,
        ROW_NUMBER() OVER (ORDER BY cust_spend DESC) AS cust_rank,
        COUNT(*) OVER () AS total_customer_count,
        SUM(cust_spend) OVER (ORDER BY cust_spend DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_spend,
        SUM(cust_spend) OVER () AS total_marketplace_spend
    FROM customer_totals
)
SELECT 
    cust_rank,
    ROUND(cust_rank * 100.0 / total_customer_count, 2) AS customer_percentile_pct,
    ROUND(cust_spend, 2) AS customer_spend,
    ROUND(running_spend, 2) AS cumulative_spend,
    ROUND(running_spend * 100.0 / total_marketplace_spend, 2) AS cumulative_gmv_share_pct
FROM ranked_customers
WHERE cust_rank IN (
    1, 10, 100, 
    CAST(total_customer_count * 0.05 AS INT), 
    CAST(total_customer_count * 0.10 AS INT), 
    CAST(total_customer_count * 0.20 AS INT), 
    CAST(total_customer_count * 0.50 AS INT),
    total_customer_count
)
ORDER BY cust_rank;

-- --------------------------------------------------------------------
-- QUESTION 35: Inter-Purchase Order Velocity using LAG() on Purchase Timestamps
-- Business Meaning:
-- Calculates the average number of days between consecutive orders for
-- repeat customers to evaluate the natural re-order cycle.
-- --------------------------------------------------------------------
WITH customer_order_seq AS (
    SELECT 
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        LAG(o.order_purchase_timestamp, 1) OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp
        ) AS previous_order_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled')
),
order_intervals AS (
    SELECT 
        customer_unique_id,
        order_id,
        ROUND((JULIANDAY(order_purchase_timestamp) - JULIANDAY(previous_order_timestamp)), 1) AS days_between_orders
    FROM customer_order_seq
    WHERE previous_order_timestamp IS NOT NULL
)
SELECT 
    COUNT(*) AS repeat_order_events,
    ROUND(AVG(days_between_orders), 1) AS avg_days_between_orders,
    ROUND(MIN(days_between_orders), 1) AS min_days_between_orders,
    ROUND(MAX(days_between_orders), 1) AS max_days_between_orders
FROM order_intervals;

-- --------------------------------------------------------------------
-- QUESTION 36: Monthly Customer Cohort Retention Matrix (2017 Cohorts)
-- Business Meaning:
-- Analyzes monthly cohort retention rates by tracking customer activity
-- across subsequent months (Month 0 to Month 6).
-- --------------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT 
        customer_unique_id,
        cohort_month
    FROM customer_rfm
    WHERE cohort_month BETWEEN '2017-01' AND '2017-06'
),
customer_orders_months AS (
    SELECT 
        c.customer_unique_id,
        cc.cohort_month,
        o.order_year_month,
        (CAST(SUBSTR(o.order_year_month, 1, 4) AS INT) - CAST(SUBSTR(cc.cohort_month, 1, 4) AS INT)) * 12 +
        (CAST(SUBSTR(o.order_year_month, 6, 2) AS INT) - CAST(SUBSTR(cc.cohort_month, 6, 2) AS INT)) AS month_index
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN customer_cohorts cc ON c.customer_unique_id = cc.customer_unique_id
    WHERE o.order_status NOT IN ('canceled')
)
SELECT 
    cohort_month,
    COUNT(DISTINCT customer_unique_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN month_index = 0 THEN customer_unique_id END) AS m0_active,
    COUNT(DISTINCT CASE WHEN month_index = 1 THEN customer_unique_id END) AS m1_active,
    COUNT(DISTINCT CASE WHEN month_index = 2 THEN customer_unique_id END) AS m2_active,
    COUNT(DISTINCT CASE WHEN month_index = 3 THEN customer_unique_id END) AS m3_active,
    COUNT(DISTINCT CASE WHEN month_index = 4 THEN customer_unique_id END) AS m4_active,
    COUNT(DISTINCT CASE WHEN month_index = 5 THEN customer_unique_id END) AS m5_active,
    COUNT(DISTINCT CASE WHEN month_index = 6 THEN customer_unique_id END) AS m6_active
FROM customer_orders_months
GROUP BY cohort_month
ORDER BY cohort_month;

-- --------------------------------------------------------------------
-- QUESTION 37: 3-Month Moving Average of GMV
-- Business Meaning:
-- Smooths monthly revenue seasonality using a 3-month rolling window.
-- --------------------------------------------------------------------
WITH monthly_gmv_data AS (
    SELECT 
        order_year_month,
        ROUND(SUM(order_subtotal), 2) AS gmv
    FROM orders
    WHERE order_year_month >= '2017-01' AND order_year_month <= '2018-08'
    GROUP BY order_year_month
)
SELECT 
    order_year_month,
    gmv AS monthly_gmv,
    ROUND(AVG(gmv) OVER (
        ORDER BY order_year_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS gmv_3month_moving_avg
FROM monthly_gmv_data;

-- --------------------------------------------------------------------
-- QUESTION 38: Customer Spend Quartiles using NTILE(4)
-- Business Meaning:
-- Segments customer accounts into 4 equal quartiles based on lifetime spend.
-- --------------------------------------------------------------------
WITH customer_quartiles AS (
    SELECT 
        customer_unique_id,
        monetary,
        NTILE(4) OVER (ORDER BY monetary DESC) AS spend_quartile
    FROM customer_rfm
)
SELECT 
    spend_quartile,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(SUM(monetary), 2) AS quartile_total_gmv,
    ROUND(SUM(monetary) * 100.0 / (SELECT SUM(monetary) FROM customer_rfm), 2) AS quartile_gmv_share_pct,
    ROUND(MIN(monetary), 2) AS min_spend,
    ROUND(MAX(monetary), 2) AS max_spend,
    ROUND(AVG(monetary), 2) AS avg_spend
FROM customer_quartiles
GROUP BY spend_quartile
ORDER BY spend_quartile;

-- --------------------------------------------------------------------
-- QUESTION 39: Top 3 Sellers by State using RANK()
-- Business Meaning:
-- Ranks sellers by revenue within their home state.
-- --------------------------------------------------------------------
WITH state_seller_revenue AS (
    SELECT 
        s.seller_state,
        s.seller_id,
        s.seller_city,
        ROUND(SUM(oi.price), 2) AS seller_gmv,
        RANK() OVER (PARTITION BY s.seller_state ORDER BY SUM(oi.price) DESC) AS rank_in_state
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_state, s.seller_id, s.seller_city
)
SELECT 
    seller_state,
    rank_in_state,
    seller_id,
    seller_city,
    seller_gmv
FROM state_seller_revenue
WHERE rank_in_state <= 3 AND seller_state IN ('SP', 'RJ', 'MG', 'PR', 'RS')
ORDER BY seller_state, rank_in_state;

-- --------------------------------------------------------------------
-- QUESTION 40: High-Revenue Products with Substandard Review Scores
-- Business Meaning:
-- Identifies top 10 products with high sales (>= R$ 5,000) that suffer
-- from poor customer satisfaction (average review score < 3.5).
-- --------------------------------------------------------------------
SELECT 
    p.product_id,
    p.category_name_english AS category,
    COUNT(oi.order_item_id) AS units_sold,
    ROUND(SUM(oi.price), 2) AS total_gmv,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN r.review_score = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS one_star_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.product_id, p.category_name_english
HAVING SUM(oi.price) >= 5000.0 AND AVG(r.review_score) < 3.50
ORDER BY total_gmv DESC
LIMIT 10;
