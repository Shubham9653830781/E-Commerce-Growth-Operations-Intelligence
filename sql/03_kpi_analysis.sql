-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 03: CORE PLATFORM KPIS & FINANCIAL MACRO TRENDS
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- --------------------------------------------------------------------
-- QUESTION 1: Executive Marketplace KPI Scorecard
-- Business Meaning:
-- Computes foundational corporate KPIs across revenue, volume, customer base,
-- logistics delivery quality, and customer satisfaction.
-- --------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,
    (SELECT COUNT(*) FROM sellers) AS total_sellers,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT ROUND(SUM(price), 2) FROM order_items) AS total_gmv_product_sales,
    (SELECT ROUND(SUM(freight_value), 2) FROM order_items) AS total_freight_billed,
    (SELECT ROUND(SUM(payment_value), 2) FROM order_payments) AS total_payments_collected,
    ROUND((SELECT SUM(price) FROM order_items) / COUNT(DISTINCT o.order_id), 2) AS average_order_value_gmv,
    ROUND((SELECT SUM(payment_value) FROM order_payments) / COUNT(DISTINCT o.order_id), 2) AS average_order_payment,
    ROUND(SUM(CASE WHEN o.order_status = 'canceled' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN o.is_late = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN o.order_status = 'delivered' THEN 1.0 ELSE 0.0 END), 0), 2) AS late_delivery_rate_pct,
    ROUND(AVG(o.review_score), 2) AS average_review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- --------------------------------------------------------------------
-- QUESTION 2: Multi-Year Platform Trajectory (2016 vs 2017 vs 2018)
-- Business Meaning:
-- Evaluates macro platform scaling from 2016 launch through peak 2018.
-- --------------------------------------------------------------------
SELECT 
    o.order_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_buyers,
    ROUND(SUM(o.order_subtotal), 2) AS annual_gmv,
    ROUND(SUM(o.order_freight), 2) AS annual_freight,
    ROUND(SUM(o.total_payment_value), 2) AS annual_payments,
    ROUND(SUM(o.order_subtotal) / COUNT(DISTINCT o.order_id), 2) AS annual_aov,
    ROUND(AVG(o.review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN o.is_late = 1 THEN 1.0 ELSE 0.0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN o.order_status = 'delivered' THEN 1.0 ELSE 0.0 END), 0), 2) AS late_delivery_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.order_year
ORDER BY o.order_year;

-- --------------------------------------------------------------------
-- QUESTION 3: Monthly Growth Trajectory & Financial Performance
-- Business Meaning:
-- Tracks month-by-month order volume, GMV, freight, and average order value.
-- --------------------------------------------------------------------
SELECT 
    o.order_year_month,
    COUNT(DISTINCT o.order_id) AS monthly_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_monthly_buyers,
    ROUND(SUM(o.order_subtotal), 2) AS monthly_gmv,
    ROUND(SUM(o.order_freight), 2) AS monthly_freight,
    ROUND(SUM(o.total_payment_value), 2) AS monthly_payments,
    ROUND(SUM(o.order_subtotal) / COUNT(DISTINCT o.order_id), 2) AS monthly_aov,
    ROUND(AVG(o.review_score), 2) AS avg_review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.order_year_month
ORDER BY o.order_year_month;

-- --------------------------------------------------------------------
-- QUESTION 4: Order Lifecycle Status Distribution
-- Business Meaning:
-- Breaks down order states: delivered, shipped, canceled, unavailable, etc.
-- --------------------------------------------------------------------
SELECT 
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders,
    ROUND(SUM(order_subtotal), 2) AS gmv_in_status,
    ROUND(SUM(order_freight), 2) AS freight_in_status
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- --------------------------------------------------------------------
-- QUESTION 5: Payment Method Distribution & Installment Dynamics
-- Business Meaning:
-- Identifies customer payment method preferences (Credit Card, Boleto,
-- Voucher, Debit Card) and average installment count.
-- --------------------------------------------------------------------
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS orders_using_method,
    COUNT(payment_sequential) AS payment_transactions,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(SUM(payment_value) * 100.0 / (SELECT SUM(payment_value) FROM order_payments), 2) AS payment_share_pct,
    ROUND(AVG(payment_installments), 2) AS avg_installments,
    ROUND(AVG(payment_value), 2) AS avg_transaction_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;
