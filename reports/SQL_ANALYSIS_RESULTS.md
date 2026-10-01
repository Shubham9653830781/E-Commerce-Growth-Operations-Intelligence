# Olist Brazilian E-Commerce SQL Analytics Execution & Business Results

**Dataset**: Brazilian E-Commerce Public Dataset by Olist  
**Database**: `ecommerce_analytics.db` (Indexed SQLite & MySQL 8 Compatible)  
**Execution Status**: 100% Executed & Verified on Actual Data  

---

## Script: `01_schema.sql`

### Query 1: 01_schema.sql - Section 1
```text
-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 01: DATABASE SCHEMA & INDEX DEFINITIONS
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================
-- 1. Customers Dimension
```

```sql
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INT NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(5) NOT NULL,
    PRIMARY KEY (customer_id)
);
```

*Executed successfully.*

---

### Query 2: 01_schema.sql - Section 2
```text
-- 2. Sellers Dimension
```

```sql
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(32) NOT NULL,
    seller_zip_code_prefix INT NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state VARCHAR(5) NOT NULL,
    PRIMARY KEY (seller_id)
);
```

*Executed successfully.*

---

### Query 3: 01_schema.sql - Section 3
```text
-- 3. Products Dimension
```

```sql
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(32) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10, 2),
    product_length_cm DECIMAL(10, 2),
    product_height_cm DECIMAL(10, 2),
    product_width_cm DECIMAL(10, 2),
    category_name_english VARCHAR(100),
    product_weight_kg DECIMAL(10, 3),
    product_volume_cm3 DECIMAL(12, 2),
    PRIMARY KEY (product_id)
);
```

*Executed successfully.*

---

### Query 4: 01_schema.sql - Section 4
```text
-- 4. Orders Fact Table
```

```sql
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME NOT NULL,
    approval_time_hours DECIMAL(10, 2),
    carrier_delivery_days DECIMAL(10, 2),
    actual_delivery_days DECIMAL(10, 2),
    estimated_delivery_days DECIMAL(10, 2),
    delivery_delay_days DECIMAL(10, 2),
    is_delivered INT NOT NULL DEFAULT 0,
    is_canceled INT NOT NULL DEFAULT 0,
    is_late INT NOT NULL DEFAULT 0,
    order_year INT NOT NULL,
    order_month INT NOT NULL,
    order_year_month VARCHAR(7) NOT NULL,
    order_day_name VARCHAR(20) NOT NULL,
    order_hour INT NOT NULL,
    total_items INT NOT NULL DEFAULT 0,
    distinct_products INT NOT NULL DEFAULT 0,
    distinct_sellers INT NOT NULL DEFAULT 0,
    order_subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    order_freight DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    order_total_value DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    payment_installments_max INT,
    payment_type_primary VARCHAR(30),
    payment_splits_count INT,
    total_payment_value DECIMAL(12, 2) DEFAULT 0.00,
    review_score DECIMAL(3, 2),
    has_review_comment INT DEFAULT 0,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

*Executed successfully.*

---

### Query 5: 01_schema.sql - Section 5
```text
-- 5. Order Items Granular Line Items Table
```

```sql
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
```

*Executed successfully.*

---

### Query 6: 01_schema.sql - Section 6
```text
-- 6. Order Payments Granular Transaction Table
```

```sql
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
```

*Executed successfully.*

---

### Query 7: 01_schema.sql - Section 7
```text
-- 7. Order Reviews Satisfaction Table
```

```sql
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME NOT NULL,
    review_answer_timestamp DATETIME NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
```

*Executed successfully.*

---

### Query 8: 01_schema.sql - Section 8
```text
-- 8. Customer RFM Segmentation Table
```

```sql
CREATE TABLE IF NOT EXISTS customer_rfm (
    customer_unique_id VARCHAR(32) NOT NULL,
    recency_days INT NOT NULL,
    frequency INT NOT NULL,
    monetary DECIMAL(12, 2) NOT NULL,
    total_spend_with_freight DECIMAL(12, 2) NOT NULL,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5),
    first_order_date DATETIME,
    last_order_date DATETIME,
    cohort_month VARCHAR(7),
    r_score INT NOT NULL,
    f_score INT NOT NULL,
    m_score INT NOT NULL,
    rfm_score VARCHAR(5) NOT NULL,
    rfm_segment VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_unique_id)
);
```

*Executed successfully.*

---

### Query 9: 01_schema.sql - Section 9
```text
-- Indexes for Query Optimization
```

```sql
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
```

*Executed successfully.*

---

### Query 10: 01_schema.sql - Section 10
```sql
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
```

*Executed successfully.*

---

### Query 11: 01_schema.sql - Section 11
```sql
CREATE INDEX IF NOT EXISTS idx_orders_purchase_date ON orders(order_purchase_timestamp);
```

*Executed successfully.*

---

### Query 12: 01_schema.sql - Section 12
```sql
CREATE INDEX IF NOT EXISTS idx_orders_year_month ON orders(order_year_month);
```

*Executed successfully.*

---

### Query 13: 01_schema.sql - Section 13
```sql
CREATE INDEX IF NOT EXISTS idx_customers_unique_id ON customers(customer_unique_id);
```

*Executed successfully.*

---

### Query 14: 01_schema.sql - Section 14
```sql
CREATE INDEX IF NOT EXISTS idx_customers_state ON customers(customer_state);
```

*Executed successfully.*

---

### Query 15: 01_schema.sql - Section 15
```sql
CREATE INDEX IF NOT EXISTS idx_items_order_id ON order_items(order_id);
```

*Executed successfully.*

---

### Query 16: 01_schema.sql - Section 16
```sql
CREATE INDEX IF NOT EXISTS idx_items_product_id ON order_items(product_id);
```

*Executed successfully.*

---

### Query 17: 01_schema.sql - Section 17
```sql
CREATE INDEX IF NOT EXISTS idx_items_seller_id ON order_items(seller_id);
```

*Executed successfully.*

---

### Query 18: 01_schema.sql - Section 18
```sql
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_name_english);
```

*Executed successfully.*

---

### Query 19: 01_schema.sql - Section 19
```sql
CREATE INDEX IF NOT EXISTS idx_sellers_state ON sellers(seller_state);
```

*Executed successfully.*

---

### Query 20: 01_schema.sql - Section 20
```sql
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON order_payments(order_id);
```

*Executed successfully.*

---

### Query 21: 01_schema.sql - Section 21
```sql
CREATE INDEX IF NOT EXISTS idx_reviews_order_id ON order_reviews(order_id);
```

*Executed successfully.*

---

### Query 22: 01_schema.sql - Section 22
```sql
CREATE INDEX IF NOT EXISTS idx_rfm_segment ON customer_rfm(rfm_segment);
```

*Executed successfully.*

---

## Script: `02_data_quality.sql`

### Query 23: 02_data_quality.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

| table_name     |   total_rows |
|:---------------|-------------:|
| orders         |        99441 |
| order_items    |       112650 |
| order_payments |       103886 |
| order_reviews  |        99224 |
| customers      |        99441 |
| sellers        |         3095 |
| products       |        32951 |
| customer_rfm   |        94697 |

*(Rows returned: 8)*

---

### Query 24: 02_data_quality.sql - Section 2
```text
-- --------------------------------------------------------------------
-- CHECK 2: Null Value Audit on Core Order Attributes
-- Expected Result: Zero nulls on critical operational fields
-- --------------------------------------------------------------------
```

```sql
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_ids,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_statuses,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamps,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_dates
FROM orders;
```

**Execution Result:**

|   total_orders |   null_order_ids |   null_customer_ids |   null_statuses |   null_purchase_timestamps |   null_estimated_dates |
|---------------:|-----------------:|--------------------:|----------------:|---------------------------:|-----------------------:|
|          99441 |                0 |                   0 |               0 |                          0 |                      0 |

*(Rows returned: 1)*

---

### Query 25: 02_data_quality.sql - Section 3
```text
-- --------------------------------------------------------------------
-- CHECK 3: Primary Key Uniqueness Across Core Entities
-- Expected Result: Total rows minus distinct PKs = 0 duplicates
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| entity    |   total_records |   unique_pks |   duplicate_pks |
|:----------|----------------:|-------------:|----------------:|
| orders    |           99441 |        99441 |               0 |
| customers |           99441 |        99441 |               0 |
| sellers   |            3095 |         3095 |               0 |
| products  |           32951 |        32951 |               0 |

*(Rows returned: 4)*

---

### Query 26: 02_data_quality.sql - Section 4
```text
-- --------------------------------------------------------------------
-- CHECK 4: Referential Integrity Check Between Tables
-- Expected Result: 0 orphaned child records
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| check_type                  |   orphan_count |
|:----------------------------|---------------:|
| order_items without order   |              0 |
| order_items without product |              0 |
| order_items without seller  |              0 |
| orders without customer     |              0 |

*(Rows returned: 4)*

---

### Query 27: 02_data_quality.sql - Section 5
```text
-- --------------------------------------------------------------------
-- CHECK 5: Delivery Date Chronological Consistency Check
-- Expected Result: Delivered customer date must never precede purchase date
-- --------------------------------------------------------------------
```

```sql
SELECT 
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN order_delivered_customer_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS delivery_before_purchase_anomalies
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
```

**Execution Result:**

|   delivered_orders |   delivery_before_purchase_anomalies |
|-------------------:|-------------------------------------:|
|              96476 |                                    0 |

*(Rows returned: 1)*

---

### Query 28: 02_data_quality.sql - Section 6
```text
-- --------------------------------------------------------------------
-- CHECK 6: Numerical Domain & Currency Sanity
-- Expected Result: Price strictly positive and freight and payments non-negative
-- --------------------------------------------------------------------
```

```sql
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_price_count,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight_count
FROM order_items;
```

**Execution Result:**

|   min_price |   max_price |   zero_or_negative_price_count |   min_freight |   max_freight |   negative_freight_count |
|------------:|------------:|-------------------------------:|--------------:|--------------:|-------------------------:|
|        0.85 |        6735 |                              0 |             0 |        409.68 |                        0 |

*(Rows returned: 1)*

---

## Script: `03_kpi_analysis.sql`

### Query 29: 03_kpi_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

|   total_orders |   total_unique_customers |   total_sellers |   total_products |   total_gmv_product_sales |   total_freight_billed |   total_payments_collected |   average_order_value_gmv |   average_order_payment |   cancellation_rate_pct |   late_delivery_rate_pct |   average_review_score |
|---------------:|-------------------------:|----------------:|-----------------:|--------------------------:|-----------------------:|---------------------------:|--------------------------:|------------------------:|------------------------:|-------------------------:|-----------------------:|
|          99441 |                    96096 |            3095 |            32951 |               1.35916e+07 |            2.25191e+06 |                1.60089e+07 |                    136.68 |                  160.99 |                    0.63 |                     8.11 |                   4.09 |

*(Rows returned: 1)*

---

### Query 30: 03_kpi_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 2: Multi-Year Platform Trajectory (2016 vs 2017 vs 2018)
-- Business Meaning:
-- Evaluates macro platform scaling from 2016 launch through peak 2018.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

|   order_year |   total_orders |   unique_buyers |      annual_gmv |   annual_freight |   annual_payments |   annual_aov |   avg_review_score |   late_delivery_pct |
|-------------:|---------------:|----------------:|----------------:|-----------------:|------------------:|-------------:|-------------------:|--------------------:|
|         2016 |            329 |             326 | 49785.9         |   7397.29        |   59362.3         |       151.32 |               3.53 |                1.5  |
|         2017 |          45101 |           43713 |     6.15581e+06 | 986865           |       7.24975e+06 |       136.49 |               4.09 |                6.63 |
|         2018 |          54011 |           52749 |     7.38605e+06 |      1.25765e+06 |       8.69976e+06 |       136.75 |               4.09 |                9.37 |

*(Rows returned: 3)*

---

### Query 31: 03_kpi_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 3: Monthly Growth Trajectory & Financial Performance
-- Business Meaning:
-- Tracks month-by-month order volume, GMV, freight, and average order value.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| order_year_month   |   monthly_orders |   unique_monthly_buyers |      monthly_gmv |   monthly_freight |   monthly_payments |   monthly_aov |   avg_review_score |
|:-------------------|-----------------:|------------------------:|-----------------:|------------------:|-------------------:|--------------:|-------------------:|
| 2016-09            |                4 |                       4 |    267.36        |             87.39 |      252.24        |         66.84 |               1    |
| 2016-10            |              324 |                     321 |  49507.7         |           7301.18 |    59090.5         |        152.8  |               3.56 |
| 2016-12            |                1 |                       1 |     10.9         |              8.72 |       19.62        |         10.9  |               5    |
| 2017-01            |              800 |                     765 | 120313           |          16875.6  |   138488           |        150.39 |               4.06 |
| 2017-02            |             1780 |                    1755 | 247303           |          38977.6  |   291908           |        138.93 |               4.02 |
| 2017-03            |             2682 |                    2642 | 374344           |          57704.3  |   449864           |        139.58 |               4.07 |
| 2017-04            |             2404 |                    2372 | 359927           |          52495    |   417788           |        149.72 |               4.05 |
| 2017-05            |             3700 |                    3625 | 506071           |          80119.8  |   592919           |        136.78 |               4.14 |
| 2017-06            |             3245 |                    3180 | 433039           |          69924.4  |   511276           |        133.45 |               4.15 |
| 2017-07            |             4026 |                    3947 | 498031           |          86940.1  |   592383           |        123.7  |               4.18 |
| 2017-08            |             4331 |                    4246 | 573972           |          94232.9  |   674396           |        132.53 |               4.24 |
| 2017-09            |             4285 |                    4212 | 624402           |          95997.2  |   727762           |        145.72 |               4.19 |
| 2017-10            |             4631 |                    4561 | 664219           |         105093    |   779678           |        143.43 |               4.12 |
| 2017-11            |             7544 |                    7430 |      1.01027e+06 |         168872    |        1.19488e+06 |        133.92 |               3.91 |
| 2017-12            |             5673 |                    5603 | 743914           |         119633    |   878401           |        131.13 |               4.02 |
| 2018-01            |             7269 |                    7166 | 950030           |         157272    |        1.115e+06   |        130.7  |               4.04 |
| 2018-02            |             6728 |                    6569 | 844179           |         142730    |   992463           |        125.47 |               3.83 |
| 2018-03            |             7211 |                    7115 | 983213           |         171913    |        1.15965e+06 |        136.35 |               3.75 |
| 2018-04            |             6939 |                    6882 | 996648           |         163050    |        1.16079e+06 |        143.63 |               4.16 |
| 2018-05            |             6873 |                    6814 | 996518           |         153264    |        1.15398e+06 |        144.99 |               4.19 |
| 2018-06            |             6167 |                    6128 | 865124           |         157553    |        1.02388e+06 |        140.28 |               4.28 |
| 2018-07            |             6292 |                    6230 | 895507           |         163221    |        1.06654e+06 |        142.32 |               4.26 |
| 2018-08            |             6512 |                    6460 | 854686           |         148622    |        1.02243e+06 |        131.25 |               4.26 |
| 2018-09            |               16 |                      14 |    145           |             21.46 |     4439.54        |          9.06 |               1.8  |
| 2018-10            |                4 |                       4 |      0           |              0    |      589.67        |          0    |               2.25 |

*(Rows returned: 25)*

---

### Query 32: 03_kpi_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 4: Order Lifecycle Status Distribution
-- Business Meaning:
-- Breaks down order states: delivered, shipped, canceled, unavailable, etc.
-- --------------------------------------------------------------------
```

```sql
SELECT 
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders,
    ROUND(SUM(order_subtotal), 2) AS gmv_in_status,
    ROUND(SUM(order_freight), 2) AS freight_in_status
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;
```

**Execution Result:**

| order_status   |   order_count |   pct_of_total_orders |    gmv_in_status |   freight_in_status |
|:---------------|--------------:|----------------------:|-----------------:|--------------------:|
| delivered      |         96478 |                 97.02 |      1.32215e+07 |         2.19828e+06 |
| shipped        |          1107 |                  1.11 | 150727           |     26401.9         |
| canceled       |           625 |                  0.63 |  95235.3         |     10650.5         |
| unavailable    |           609 |                  0.61 |   2007.69        |       132.8         |
| invoiced       |           314 |                  0.32 |  61526.4         |      7462.38        |
| processing     |           301 |                  0.3  |  60439.2         |      8954.89        |
| created        |             5 |                  0.01 |      0           |         0           |
| approved       |             2 |                  0    |    209.6         |        31.48        |

*(Rows returned: 8)*

---

### Query 33: 03_kpi_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 5: Payment Method Distribution & Installment Dynamics
-- Business Meaning:
-- Identifies customer payment method preferences (Credit Card, Boleto,
-- Voucher, Debit Card) and average installment count.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| payment_type   |   orders_using_method |   payment_transactions |   total_payment_value |   payment_share_pct |   avg_installments |   avg_transaction_value |
|:---------------|----------------------:|-----------------------:|----------------------:|--------------------:|-------------------:|------------------------:|
| credit_card    |                 76505 |                  76795 |           1.25421e+07 |               78.34 |               3.51 |                  163.32 |
| boleto         |                 19784 |                  19784 |           2.86936e+06 |               17.92 |               1    |                  145.03 |
| voucher        |                  3866 |                   5775 |      379437           |                2.37 |               1    |                   65.7  |
| debit_card     |                  1528 |                   1529 |      217990           |                1.36 |               1    |                  142.57 |
| not_defined    |                     3 |                      3 |           0           |                0    |               1    |                    0    |

*(Rows returned: 5)*

---

## Script: `04_customer_analysis.sql`

### Query 34: 04_customer_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

|   total_active_customers |   one_time_buyers |   repeat_buyers |   repeat_customer_rate_pct |   avg_orders_per_customer |   avg_lifetime_spend_per_customer |
|-------------------------:|------------------:|----------------:|---------------------------:|--------------------------:|----------------------------------:|
|                    95560 |             92636 |            2924 |                       3.06 |                     1.034 |                            141.23 |

*(Rows returned: 1)*

---

### Query 35: 04_customer_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 7: Customer Order Frequency Distribution
-- Business Meaning:
-- Groups customers into frequency cohorts to evaluate retention drop-off.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| buyer_frequency_tier         |   customer_count |   customer_share_pct |    aggregate_gmv |   gmv_contribution_pct |   avg_spend_per_customer |
|:-----------------------------|-----------------:|---------------------:|-----------------:|-----------------------:|-------------------------:|
| 1. One-Time Buyer (1 Order)  |            92636 |                96.94 |      1.27419e+07 |                  94.41 |                   137.55 |
| 2. Repeat Buyer (2 Orders)   |             2688 |                 2.81 | 654962           |                   4.85 |                   243.66 |
| 3. Frequent Buyer (3 Orders) |              187 |                 0.2  |  67609.2         |                   0.5  |                   361.55 |
| 4. Power Buyer (4+ Orders)   |               49 |                 0.05 |  31895.3         |                   0.24 |                   650.92 |

*(Rows returned: 4)*

---

### Query 36: 04_customer_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 8: Top 10 High-Value Customers by Historical GMV
-- Business Meaning:
-- Identifies VIP accounts, their order counts, and primary geographic state.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_unique_id               | customer_state   | customer_city   |   orders_placed |   items_purchased |   total_product_spend |   total_freight_paid |   total_order_value |
|:---------------------------------|:-----------------|:----------------|----------------:|------------------:|----------------------:|---------------------:|--------------------:|
| 0a0a92112bd4c708ca5fde585afaa872 | RJ               | rio de janeiro  |               1 |                 8 |               13440   |               224.08 |            13664.1  |
| da122df9eeddfedc1dc1f5349a1a690c | RJ               | araruama        |               2 |                 2 |                7388   |               183.63 |             7571.63 |
| 763c8b1c9c68a0229c42c9fc6f662b93 | ES               | vila velha      |               1 |                 4 |                7160   |               114.88 |             7274.88 |
| dc4802a71eae9be1dd28f5d788ceb526 | MS               | campo grande    |               1 |                 1 |                6735   |               194.31 |             6929.31 |
| 459bef486812aa25204be022145caa62 | ES               | vitoria         |               1 |                 1 |                6729   |               193.21 |             6922.21 |
| ff4159b92c40ebe40454e3e6a7c35ed6 | SP               | marilia         |               1 |                 1 |                6499   |               227.66 |             6726.66 |
| 4007669dec559734d6f53e029e360987 | MG               | divinopolis     |               1 |                 6 |                5934.6 |               146.94 |             6081.54 |
| eebb5dda148d3893cdaf5b5ca3040ccb | SP               | maua            |               1 |                 1 |                4690   |                74.34 |             4764.34 |
| 48e1ac109decbb87765a3eade6854098 | PB               | joao pessoa     |               1 |                 1 |                4590   |                91.78 |             4681.78 |
| a229eba70ec1c2abef51f04987deb7a5 | RJ               | niteroi         |               1 |                 2 |                4400   |                45.5  |             4445.5  |

*(Rows returned: 10)*

---

### Query 37: 04_customer_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 9: Geographic Customer Distribution by State
-- Business Meaning:
-- Measures customer demand, revenue, and AOV across all 27 Brazilian states.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_state   |   unique_customers |   total_orders |        state_gmv |   gmv_share_pct |   state_freight |   state_aov |   avg_customer_review |
|:-----------------|-------------------:|---------------:|-----------------:|----------------:|----------------:|------------:|----------------------:|
| SP               |              40302 |          41746 |      5.20296e+06 |           38.28 |        718723   |      124.63 |                  4.17 |
| RJ               |              12384 |          12852 |      1.82409e+06 |           13.42 |        305589   |      141.93 |                  3.88 |
| MG               |              11259 |          11635 |      1.58531e+06 |           11.66 |        270853   |      136.25 |                  4.14 |
| RS               |               5277 |           5466 | 750304           |            5.52 |        135523   |      137.27 |                  4.13 |
| PR               |               4882 |           5045 | 683084           |            5.03 |        117852   |      135.4  |                  4.18 |
| SC               |               3534 |           3637 | 520553           |            3.83 |         89660.3 |      143.13 |                  4.07 |
| BA               |               3277 |           3380 | 511350           |            3.76 |        100157   |      151.29 |                  3.86 |
| DF               |               2075 |           2140 | 302604           |            2.23 |         50625.5 |      141.4  |                  4.07 |
| GO               |               1952 |           2020 | 294592           |            2.17 |         53115   |      145.84 |                  4.04 |
| ES               |               1964 |           2033 | 275037           |            2.02 |         49764.6 |      135.29 |                  4.04 |
| PE               |               1609 |           1652 | 262788           |            1.93 |         59449.7 |      159.07 |                  4.01 |
| CE               |               1313 |           1336 | 227255           |            1.67 |         48351.6 |      170.1  |                  3.85 |
| PA               |                949 |            975 | 178948           |            1.32 |         38699.3 |      183.54 |                  3.85 |
| MT               |                876 |            907 | 156454           |            1.15 |         29715.4 |      172.5  |                  4.1  |
| MA               |                726 |            747 | 119648           |            0.88 |         31523.8 |      160.17 |                  3.76 |
| MS               |                694 |            715 | 116813           |            0.86 |         19144   |      163.37 |                  4.11 |
| PB               |                519 |            536 | 115268           |            0.85 |         25719.7 |      215.05 |                  4.02 |
| PI               |                482 |            495 |  86914.1         |            0.64 |         21218.2 |      175.58 |                  3.92 |
| RN               |                474 |            485 |  83035           |            0.61 |         18860.1 |      171.21 |                  4.11 |
| AL               |                401 |            413 |  80314.8         |            0.59 |         15914.6 |      194.47 |                  3.76 |

*... (Showing top 20 rows of 27 total rows returned)*


*(Rows returned: 27)*

---

### Query 38: 04_customer_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 10: Top 10 Metro Cities by Customer Demand & Revenue
-- Business Meaning:
-- Identifies prime urban clusters for localized marketing and warehousing.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_city   | customer_state   |   unique_customers |   total_orders |         city_gmv |   city_freight |   city_aov |
|:----------------|:-----------------|-------------------:|---------------:|-----------------:|---------------:|-----------:|
| sao paulo       | SP               |              14984 |          15540 |      1.91492e+06 |       255303   |     123.23 |
| rio de janeiro  | RJ               |               6620 |           6882 | 992539           |       161695   |     144.22 |
| belo horizonte  | MG               |               2672 |           2773 | 355611           |        61122.3 |     128.24 |
| brasilia        | DF               |               2069 |           2131 | 301920           |        50384.9 |     141.68 |
| curitiba        | PR               |               1465 |           1521 | 211738           |        33001.8 |     139.21 |
| porto alegre    | RS               |               1326 |           1379 | 190562           |        33502   |     138.19 |
| campinas        | SP               |               1398 |           1444 | 187845           |        24697.2 |     130.09 |
| salvador        | BA               |               1209 |           1245 | 181104           |        35668   |     145.47 |
| guarulhos       | SP               |               1153 |           1189 | 144268           |        19307.4 |     121.34 |
| niteroi         | RJ               |                811 |            849 | 117907           |        20012.3 |     138.88 |

*(Rows returned: 10)*

---

## Script: `05_rfm_analysis.sql`

### Query 39: 05_rfm_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

| rfm_segment               |   customer_count |   customer_share_pct |      segment_gmv |   gmv_contribution_pct |   avg_recency_days |   avg_frequency |   avg_spend_per_customer |
|:--------------------------|-----------------:|---------------------:|-----------------:|-----------------------:|-------------------:|----------------:|-------------------------:|
| Recent New Buyers         |            36665 |                38.72 |      5.15783e+06 |                  38.39 |              139.9 |            1    |                   140.67 |
| Hibernating High Spenders |            13763 |                14.53 |      3.83149e+06 |                  28.52 |              445.5 |            1    |                   278.39 |
| Promising Regulars        |            18592 |                19.63 |      2.42109e+06 |                  18.02 |              270.2 |            1    |                   130.22 |
| Lost / Inactive           |            22801 |                24.08 |      1.27569e+06 |                   9.5  |              446.1 |            1    |                    55.95 |
| Champions                 |             1235 |                 1.3  | 333120           |                   2.48 |              138.2 |            2.16 |                   269.73 |
| Loyal Customers           |              628 |                 0.66 | 162781           |                   1.21 |              268   |            2.09 |                   259.21 |
| At Risk                   |              563 |                 0.59 | 143478           |                   1.07 |              368.2 |            2.08 |                   254.85 |
| Cant Lose Them            |              450 |                 0.48 | 108273           |                   0.81 |              515.2 |            2.08 |                   240.61 |

*(Rows returned: 8)*

---

### Query 40: 05_rfm_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 12: VIP Champions & Loyal Customers Deep Dive
-- Business Meaning:
-- Analyzes highest-value buyers with repeat purchases and recent activity.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_unique_id               | customer_city         | customer_state   |   recency_days |   frequency |   total_gmv |   total_with_freight | cohort_month   | rfm_segment     |
|:---------------------------------|:----------------------|:-----------------|---------------:|------------:|------------:|---------------------:|:---------------|:----------------|
| c8460e4251689ba205045f3ea17884a1 | porto alegre          | RS               |             71 |           4 |     4080    |              4655.88 | 2018-08        | Champions       |
| 7b0eaf68a16e4808e5388c67345033c9 | ferraz de vasconcelos | SP               |            152 |           2 |     2238.42 |              2340.08 | 2018-05        | Champions       |
| 6ddbc64bd04d40f7768ff088d94cbeb8 | campinas              | SP               |            191 |           2 |     2108    |              2299.66 | 2018-04        | Champions       |
| 1da09dd64e235e7c2f29a4faff33535c | niteroi               | RJ               |            280 |           3 |     1980.28 |              2164.4  | 2017-05        | Loyal Customers |
| 906a8a4ec9f3d4c3e64fa6d1c4fe6009 | sao jose do rio preto | SP               |             90 |           2 |     1835    |              2020.83 | 2018-07        | Champions       |
| 0341bbd5c969923a0f801b9e2d10a7b8 | petropolis            | RJ               |            141 |           2 |     1828.44 |              1999.68 | 2018-05        | Champions       |
| eae0a83d752b1dd32697e0e7b4221656 | cicero dantas         | BA               |            177 |           2 |     1821.73 |              2783.01 | 2018-02        | Champions       |
| 798c34ffa9047399853eab8ca7c0b9a0 | lavras                | MG               |            317 |           2 |     1770.3  |              1812.19 | 2017-12        | Loyal Customers |
| cef29e793e232d30250331804cdb7000 | belo horizonte        | MG               |            272 |           3 |     1712.72 |              1906.68 | 2017-03        | Loyal Customers |
| 4facc2e6fbc2bffab2fea92d2b4aa7e4 | porto alegre          | RS               |             65 |           4 |     1686.9  |              1760.75 | 2017-06        | Champions       |
| 525cda9909aa001ebed396f6e55eae01 | timbo                 | SC               |             71 |           2 |     1684.29 |              1782.9  | 2018-07        | Champions       |
| a1044dd75b74fbc485b040575a14acf0 | cerqueira cesar       | SP               |            301 |           2 |     1663    |              1737.88 | 2017-12        | Loyal Customers |
| 397b44d5bb99eabf54ea9c2b41ebb905 | niteroi               | RJ               |            122 |           4 |     1650    |              1756.53 | 2018-01        | Champions       |
| 87c9e7ba960e4c2e6bd786b162adc639 | maceio                | AL               |            158 |           2 |     1597.8  |              1653.98 | 2018-05        | Champions       |
| fe81bb32c243a86b2f86fbf053fe6140 | sao paulo             | SP               |            119 |           5 |     1535.4  |              1590.76 | 2017-10        | Champions       |

*(Rows returned: 15)*

---

### Query 41: 05_rfm_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 13: At-Risk & High-Value Hibernating Customers ("Churn Risk")
-- Business Meaning:
-- Identifies formerly high-spending buyers who haven't ordered recently.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_unique_id               | customer_state   |   recency_days |   frequency |   total_historical_spend | rfm_segment               |
|:---------------------------------|:-----------------|---------------:|------------:|-------------------------:|:--------------------------|
| 0a0a92112bd4c708ca5fde585afaa872 | RJ               |            384 |           1 |                 13440    | Hibernating High Spenders |
| da122df9eeddfedc1dc1f5349a1a690c | RJ               |            565 |           2 |                  7388    | Cant Lose Them            |
| dc4802a71eae9be1dd28f5d788ceb526 | MS               |            612 |           1 |                  6735    | Hibernating High Spenders |
| ff4159b92c40ebe40454e3e6a7c35ed6 | SP               |            511 |           1 |                  6499    | Hibernating High Spenders |
| 4007669dec559734d6f53e029e360987 | MG               |            328 |           1 |                  5934.6  | Hibernating High Spenders |
| eebb5dda148d3893cdaf5b5ca3040ccb | SP               |            547 |           1 |                  4690    | Hibernating High Spenders |
| 011875f0176909c5cf0b14a9138bb691 | SP               |            578 |           1 |                  3999.9  | Hibernating High Spenders |
| edf81e1f3070b9dac83ec83dacdbb9bc | DF               |            547 |           1 |                  3999    | Hibernating High Spenders |
| 5e713be0853d8986528d7869a0811d2b | PA               |            620 |           1 |                  3980    | Hibernating High Spenders |
| 5d09b0d82126457e2a8ebfb9c9a1ffc4 | DF               |            615 |           1 |                  3699.99 | Hibernating High Spenders |
| 931eabdf0636b8fd60369a8d759917d6 | SC               |            526 |           1 |                  3597    | Hibernating High Spenders |
| 03796b63235e0e0a299084988c662c7e | DF               |            603 |           1 |                  3549    | Hibernating High Spenders |
| 59d66d72939bc9497e19d89c61a96d5f | SP               |            433 |           2 |                  3459    | Cant Lose Them            |
| 895617ab63a9ad8881d9470f7427cd25 | PR               |            377 |           1 |                  2999.99 | Hibernating High Spenders |
| c6111f70f40b3420e387493c627c27fa | RJ               |            373 |           1 |                  2999.99 | Hibernating High Spenders |

*(Rows returned: 15)*

---

### Query 42: 05_rfm_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 14: Recency Score vs Monetary Score Matrix
-- Business Meaning:
-- Evaluates relationship between customer purchase freshness and spend level.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

|   r_score |   customer_count |   avg_recency |   avg_monetary_spend |   top_tier_monetary_customers |   lowest_tier_monetary_customers |
|----------:|-----------------:|--------------:|---------------------:|------------------------------:|---------------------------------:|
|         5 |            19044 |          95   |               143.51 |                          3772 |                             3950 |
|         4 |            18856 |         185.1 |               146.26 |                          3812 |                             3744 |
|         3 |            19220 |         270.1 |               134.44 |                          3709 |                             4047 |
|         2 |            18644 |         366.5 |               144.75 |                          3739 |                             3691 |
|         1 |            18933 |         523.4 |               140.51 |                          3776 |                             4165 |

*(Rows returned: 5)*

---

### Query 43: 05_rfm_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 15: Repeat Customer State Distribution
-- Business Meaning:
-- Identifies which states produce the highest density of repeat buyers.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_state   |   total_customers |   repeat_buyers |   repeat_buyer_pct |        state_gmv |
|:-----------------|------------------:|----------------:|-------------------:|-----------------:|
| RJ               |             12206 |             412 |               3.38 |      1.80414e+06 |
| MT               |               870 |              29 |               3.33 | 155790           |
| GO               |              1928 |              61 |               3.16 | 287689           |
| SP               |             39612 |            1247 |               3.15 |      5.13697e+06 |
| RS               |              5220 |             162 |               3.1  | 740615           |
| ES               |              1948 |              58 |               2.98 | 273539           |
| DF               |              2048 |              61 |               2.98 | 299674           |
| PR               |              4809 |             143 |               2.97 | 674384           |
| MG               |             11100 |             327 |               2.95 |      1.56829e+06 |
| BA               |              3234 |              91 |               2.81 | 505093           |
| SC               |              3483 |              93 |               2.67 | 513721           |
| MS               |               683 |              18 |               2.64 | 116089           |
| PA               |               942 |              23 |               2.44 | 178322           |
| MA               |               714 |              17 |               2.38 | 119007           |
| PB               |               513 |              12 |               2.34 | 114414           |
| PE               |              1585 |              35 |               2.21 | 258902           |
| CE               |              1295 |              21 |               1.62 | 224814           |

*(Rows returned: 17)*

---

## Script: `06_product_analysis.sql`

### Query 44: 06_product_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

| product_category      |   items_sold |   distinct_orders |     category_gmv |   gmv_share_pct |   category_freight |   avg_item_price |
|:----------------------|-------------:|------------------:|-----------------:|----------------:|-------------------:|-----------------:|
| health_beauty         |         9670 |              8836 |      1.25868e+06 |            9.26 |           182567   |           130.16 |
| watches_gifts         |         5991 |              5624 |      1.20501e+06 |            8.87 |           100536   |           201.14 |
| bed_bath_table        |        11115 |              9417 |      1.03699e+06 |            7.63 |           204693   |            93.3  |
| sports_leisure        |         8641 |              7720 | 988049           |            7.27 |           168608   |           114.34 |
| computers_accessories |         7827 |              6689 | 911954           |            6.71 |           147318   |           116.51 |
| furniture_decor       |         8334 |              6449 | 729762           |            5.37 |           172749   |            87.56 |
| cool_stuff            |         3796 |              3632 | 635291           |            4.67 |            84039.1 |           167.36 |
| housewares            |         6964 |              5884 | 632249           |            4.65 |           146149   |            90.79 |
| auto                  |         4235 |              3897 | 592720           |            4.36 |            92664.2 |           139.96 |
| garden_tools          |         4347 |              3518 | 485256           |            3.57 |            98962.8 |           111.63 |

*(Rows returned: 10)*

---

### Query 45: 06_product_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 17: Top 10 Individual Products by Lifetime GMV
-- Business Meaning:
-- Identifies the single highest revenue-generating SKUs on the platform.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| product_id                       | category              |   units_sold |   total_product_sales |   avg_selling_price |   product_avg_review |
|:---------------------------------|:----------------------|-------------:|----------------------:|--------------------:|---------------------:|
| bb50f2e236e5eea0100680137654686c | health_beauty         |          195 |               63885   |              327.62 |                 4.22 |
| 6cdd53843498f92890544667809f1595 | health_beauty         |          156 |               54730.2 |              350.83 |                 4.32 |
| d6160fb7873f184099d9bc95e30376af | computers             |           35 |               48899.3 |             1397.12 |                 4.57 |
| d1c427060a0f73f6b889a5c7c61f2ac4 | computers_accessories |          343 |               47214.5 |              137.65 |                 4.19 |
| 99a4788cb24856965c36a24e339b6058 | bed_bath_table        |          488 |               43025.6 |               88.17 |                 3.9  |
| 3dd2a17168ec895c781a9191c1e95ad7 | computers_accessories |          274 |               41082.6 |              149.94 |                 4.21 |
| 25c38557cf793876c5abdd5931f922db | baby                  |           38 |               38907.3 |             1023.88 |                 2.68 |
| 5f504b3a1c75b73d6151be81eb05bdc9 | cool_stuff            |           63 |               37733.9 |              598.95 |                 4.56 |
| 53b36df67ebb7c41585e8d54d6772e08 | watches_gifts         |          323 |               37683.4 |              116.67 |                 4.19 |
| aca2eb7d00ea1a7b8ebd4e68314663af | furniture_decor       |          527 |               37608.9 |               71.36 |                 4.02 |

*(Rows returned: 10)*

---

### Query 46: 06_product_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 18: Top 10 Categories by Customer Satisfaction (Highest Review Scores)
-- Business Meaning:
-- Identifies product lines with exceptional customer satisfaction (min 100 orders).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| product_category       |   total_orders |   avg_review_score |   five_star_pct |   one_star_pct |
|:-----------------------|---------------:|-------------------:|----------------:|---------------:|
| books_general_interest |            508 |               4.45 |           72.5  |           7.1  |
| books_technical        |            257 |               4.37 |           70.68 |           8.27 |
| food_drink             |            226 |               4.32 |           63.8  |           6.09 |
| luggage_accessories    |           1030 |               4.32 |           64.8  |           7.35 |
| fashion_shoes          |            236 |               4.23 |           63.6  |           8.81 |
| food                   |            445 |               4.22 |           63.23 |          10.3  |
| pet_shop               |           1701 |               4.19 |           61.68 |           9.9  |
| stationery             |           2295 |               4.19 |           61.59 |           9.85 |
| computers              |            178 |               4.18 |           61    |          12    |
| home_appliances        |            761 |               4.17 |           59.55 |          10.17 |

*(Rows returned: 10)*

---

### Query 47: 06_product_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 19: Categories with Quality & Customer Satisfaction Issues
-- Business Meaning:
-- Flags categories with lowest review scores and high negative sentiment.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| product_category          |   total_orders |   avg_review_score |   one_star_pct |   five_star_pct |
|:--------------------------|---------------:|-------------------:|---------------:|----------------:|
| office_furniture          |           1263 |               3.49 |          21.04 |           36.75 |
| fashion_male_clothing     |            111 |               3.64 |          25.95 |           51.91 |
| fixed_telephony           |            214 |               3.68 |          19.08 |           45.8  |
| audio                     |            347 |               3.83 |          16.62 |           52.63 |
| home_confort              |            395 |               3.83 |          16.55 |           52.87 |
| construction_tools_safety |            166 |               3.84 |          18.13 |           51.81 |
| unclassified              |           1439 |               3.84 |          18.15 |           52.75 |
| bed_bath_table            |           9313 |               3.9  |          14.49 |           51.94 |
| furniture_decor           |           6398 |               3.9  |          15.12 |           53.44 |
| furniture_living_room     |            417 |               3.9  |          13.35 |           51    |

*(Rows returned: 10)*

---

### Query 48: 06_product_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 20: Product Physical Weight & Volume vs Freight Cost Burden
-- Business Meaning:
-- Measures how product bulkiness impacts freight value and delivery delays.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| product_category                        |   items_sold |   avg_weight_kg |   avg_price |   avg_freight |   freight_to_price_ratio_pct |   avg_delivery_days |
|:----------------------------------------|-------------:|----------------:|------------:|--------------:|-----------------------------:|--------------------:|
| office_furniture                        |         1668 |           11.34 |      160.76 |         40.2  |                        25.01 |                20.8 |
| kitchen_dining_laundry_garden_furniture |          274 |            8.94 |      166.18 |         42.12 |                        25.35 |                11.9 |
| home_appliances_2                       |          231 |            8.93 |      467.33 |         44.39 |                         9.5  |                13.9 |
| furniture_living_room                   |          495 |            8.1  |      136.06 |         35.75 |                        26.27 |                13.8 |
| industry_commerce_and_business          |          265 |            6.6  |      145.28 |         28.61 |                        19.69 |                10.8 |
| luggage_accessories                     |         1077 |            5.8  |      128.79 |         27.93 |                        21.68 |                10.7 |
| air_conditioning                        |          289 |            4.09 |      184.51 |         22.6  |                        12.25 |                12.3 |
| agro_industry_and_commerce              |          206 |            3.68 |      342.55 |         27.37 |                         7.99 |                11.6 |
| construction_tools_lights               |          301 |            3.39 |      132.75 |         24.88 |                        18.75 |                 9.7 |
| baby                                    |         2982 |            3.26 |      134.28 |         22.24 |                        16.56 |                12.5 |

*(Rows returned: 10)*

---

## Script: `07_seller_analysis.sql`

### Query 49: 07_seller_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

| seller_id                        | seller_city      | seller_state   |   total_items_sold |   total_orders |   total_seller_gmv |   total_freight_generated |   avg_seller_review |
|:---------------------------------|:-----------------|:---------------|-------------------:|---------------:|-------------------:|--------------------------:|--------------------:|
| 4869f7a5dfa277a7dca6462dcf3b52b2 | guariba          | SP             |               1156 |           1132 |             229473 |                  20168.1  |                4.12 |
| 53243585a1d6dc2643021fd1853d8905 | lauro de freitas | BA             |                410 |            358 |             222776 |                  13080.6  |                4.08 |
| 4a3ca9315b744ce9f8e9374361493884 | ibitinga         | SP             |               2009 |           1806 |             202999 |                  35441.2  |                3.8  |
| fa1c13f2614d7b5c4749cbc52fecda94 | sumare           | SP             |                586 |            585 |             194042 |                  10042.7  |                4.34 |
| 7c67e1448b00f6e969d365cea6b010ab | itaquaquecetuba  | SP             |               1375 |            982 |             189418 |                  51957.2  |                3.35 |
| 7e93a43ef30c4f03f38b393420bc753a | barueri          | SP             |                340 |            336 |             176432 |                   6322.18 |                4.21 |
| da8622b14eb17ae2831f4ac5b9dab84a | piracicaba       | SP             |               1574 |           1314 |             162723 |                  25339.1  |                4.07 |
| 7a67c85e85bb2ce8582c35f2203ad736 | sao paulo        | SP             |               1175 |           1160 |             142325 |                  20953.3  |                4.23 |
| 1025f0e2d44d7041d6cf58b6550e0bfa | sao paulo        | SP             |               1443 |            915 |             140513 |                  34197.7  |                3.85 |
| 955fee9216a65b617aa5c0531780ce60 | sao paulo        | SP             |               1501 |           1287 |             135242 |                  25453.2  |                4.05 |

*(Rows returned: 10)*

---

### Query 50: 07_seller_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 22: Seller Volume Tiers & Revenue Concentration
-- Business Meaning:
-- Categorizes sellers into volume tiers: 1-10 items, 11-50, 51-200, 201-500, 500+ items.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| seller_tier                           |   seller_count |   seller_share_pct |   aggregate_tier_gmv |   gmv_share_pct |   avg_gmv_per_seller |
|:--------------------------------------|---------------:|-------------------:|---------------------:|----------------:|---------------------:|
| 1. Boutique / Small (1-10 items)      |           1784 |              57.64 |          1.21491e+06 |            8.94 |               681    |
| 2. Emerging Merchant (11-50 items)    |            849 |              27.43 |          3.0269e+06  |           22.27 |              3565.25 |
| 3. Established Seller (51-200 items)  |            360 |              11.63 |          4.07477e+06 |           29.98 |             11318.8  |
| 4. High-Volume Seller (201-500 items) |             73 |               2.36 |          2.56889e+06 |           18.9  |             35190.3  |
| 5. Enterprise Anchor (500+ items)     |             29 |               0.94 |          2.70617e+06 |           19.91 |             93316.3  |

*(Rows returned: 5)*

---

### Query 51: 07_seller_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 23: Sellers with Operational Delivery & Satisfaction Risk
-- Business Meaning:
-- Flags sellers with high volume (>= 50 items) who exhibit elevated
-- late delivery rates (> 15%) or substandard average review scores (< 3.8).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| seller_id                        | seller_city    | seller_state   |   total_orders |   seller_gmv |   avg_review_score |   late_delivery_rate_pct |   avg_delivery_days |
|:---------------------------------|:---------------|:---------------|---------------:|-------------:|-------------------:|-------------------------:|--------------------:|
| 2a261b5b644fa05f4f2700eb93544f2c | porto ferreira | SP             |             51 |      5405    |               3.34 |                    37.25 |                14.8 |
| 54965bbe3e4f07ae045b90b0b8541f52 | foz do iguacu  | PR             |             73 |     10351.7  |               3.07 |                    35.62 |                26.7 |
| 6039e27294dc75811c0d8a39069f52c0 | osasco         | SP             |             63 |     13630.7  |               3.88 |                    30.16 |                18   |
| bbad7e518d7af88a0897397ffdca1979 | sao paulo      | SP             |             68 |      4426.32 |               3.05 |                    27.94 |                15.3 |
| a49928bcdf77c55c6d6e05e09a9b4ca5 | sao paulo      | SP             |             96 |      8646.9  |               2.97 |                    27.08 |                16.9 |
| cac4c8e7b1ca6252d8f20b2fc1a2e4af | indaiatuba     | SP             |             74 |      4228.18 |               3.55 |                    27.03 |                19.9 |
| beadbee30901a7f61d031b6b686095ad | guarulhos      | SP             |             64 |      4373.98 |               3.94 |                    25    |                13.5 |
| 06a2c3af7b3aee5d69171b0e14f0ee87 | sao luis       | MA             |            389 |     36221    |               4.03 |                    24.42 |                17.7 |
| ea566164622c6b439516ab18062c42cd | sao  paulo     | SP             |             50 |     10309.4  |               3.75 |                    24    |                14.2 |
| 88460e8ebdecbfecb5f9601833981930 | maringa        | PR             |            246 |     32184.5  |               3.37 |                    23.98 |                18.3 |

*(Rows returned: 10)*

---

### Query 52: 07_seller_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 24: Top 10 Operational Excellence Sellers
-- Business Meaning:
-- Identifies top-tier sellers with high volume (>= 100 orders),
-- high review scores (>= 4.2), and low late delivery rates (< 5%).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| seller_id                        | seller_city    | seller_state   |   total_orders |   seller_gmv |   avg_review_score |   late_delivery_rate_pct |   avg_delivery_days |
|:---------------------------------|:---------------|:---------------|---------------:|-------------:|-------------------:|-------------------------:|--------------------:|
| 37be5a7c751166fbc5f8ccba4119e043 | sao paulo      | SP             |            269 |      55525.5 |               4.31 |                     2.6  |                10.6 |
| c3cfdc648177fdbbbb35635a37472c53 | curitiba       | PR             |            278 |      43966.6 |               4.45 |                     2.52 |                 9.8 |
| 4d6d651bd7684af3fffabd5f08d12e5a | jau            | SP             |            363 |      43317.9 |               4.21 |                     4.96 |                13.1 |
| dbc22125167c298ef99da25668e1011f | borda da mata  | MG             |            394 |      32938   |               4.27 |                     2.54 |                11.4 |
| 12b9676b00f60f3b700e83af21824c0e | montenegro     | RS             |            133 |      26575   |               4.53 |                     2.26 |                15.2 |
| a3a38f4affed601eb87a97788c949667 | joinville      | SC             |            251 |      26294.6 |               4.4  |                     4.78 |                12.5 |
| 612170e34b97004b3ba37eae81836b4c | novo hamburgo  | RS             |            107 |      23065   |               4.43 |                     1.87 |                10.9 |
| 1e8b33f18b4f7598d87f5cbee2282cc2 | sao paulo      | SP             |            122 |      17233.6 |               4.31 |                     4.92 |                 7.8 |
| 85d9eb9ddc5d00ca9336a2219c97bb13 | belo horizonte | MG             |            499 |      15198.9 |               4.21 |                     3.61 |                14.7 |
| 2a84855fd20af891be03bc5924d2b453 | belo horizonte | MG             |            155 |      14989   |               4.36 |                     3.23 |                 8.5 |

*(Rows returned: 10)*

---

### Query 53: 07_seller_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 25: Seller Geographic Distribution by State
-- Business Meaning:
-- Tracks seller origination hubs and cross-border geographic presence.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| seller_state   |   unique_sellers |   total_items_shipped |   total_origin_gmv |   gmv_share_pct |
|:---------------|-----------------:|----------------------:|-------------------:|----------------:|
| SP             |             1849 |                 80342 |        8.7534e+06  |           64.4  |
| PR             |              349 |                  8671 |        1.26189e+06 |            9.28 |
| MG             |              244 |                  8827 |        1.01156e+06 |            7.44 |
| RJ             |              171 |                  4818 |   843984           |            6.21 |
| SC             |              190 |                  4075 |   632426           |            4.65 |
| RS             |              129 |                  2199 |   378560           |            2.79 |
| BA             |               19 |                   643 |   285562           |            2.1  |
| DF             |               30 |                   899 |    97749.5         |            0.72 |
| PE             |                9 |                   448 |    91493.9         |            0.67 |
| GO             |               40 |                   520 |    66399.2         |            0.49 |

*(Rows returned: 10)*

---

## Script: `08_operations_analysis.sql`

### Query 54: 08_operations_analysis.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

|   delivered_orders |   avg_approval_time_hours |   avg_carrier_handoff_days |   avg_in_transit_days |   avg_total_delivery_days |   avg_estimated_delivery_days |   avg_days_ahead_of_schedule |
|-------------------:|--------------------------:|---------------------------:|----------------------:|--------------------------:|------------------------------:|-----------------------------:|
|              95105 |                      9.65 |                       2.85 |                  9.76 |                     12.62 |                         23.75 |                       -11.13 |

*(Rows returned: 1)*

---

### Query 55: 08_operations_analysis.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 27: Delivery Logistics Performance by Customer State
-- Business Meaning:
-- Identifies states with highest fulfillment delays and longest delivery times.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| customer_state   |   total_delivered_orders |   avg_delivery_days |   avg_estimated_days |   late_orders |   late_delivery_rate_pct |   avg_freight_paid |   avg_customer_review |
|:-----------------|-------------------------:|--------------------:|---------------------:|--------------:|-------------------------:|-------------------:|----------------------:|
| AL               |                      397 |                24.5 |                 32.6 |            95 |                    23.93 |              38.58 |                  3.85 |
| MA               |                      717 |                21.6 |                 30.5 |           141 |                    19.67 |              42.95 |                  3.83 |
| PI               |                      476 |                19.5 |                 30.1 |            76 |                    15.97 |              42.98 |                  3.99 |
| CE               |                     1279 |                21.3 |                 31.4 |           196 |                    15.32 |              36.5  |                  3.94 |
| SE               |                      335 |                21.5 |                 30.8 |            51 |                    15.22 |              40.94 |                  3.91 |
| BA               |                     3256 |                19.3 |                 29.4 |           457 |                    14.04 |              29.96 |                  3.93 |
| RJ               |                    12350 |                15.3 |                 26.4 |          1664 |                    13.47 |              23.95 |                  3.97 |
| TO               |                      274 |                17.7 |                 29.1 |            35 |                    12.77 |              42.35 |                  4.15 |
| PA               |                      946 |                23.8 |                 37.2 |           117 |                    12.37 |              39.7  |                  3.91 |
| ES               |                     1995 |                15.8 |                 25.6 |           244 |                    12.23 |              24.57 |                  4.08 |
| RR               |                       41 |                29.4 |                 46   |             5 |                    12.2  |              48.34 |                  3.9  |
| MS               |                      701 |                15.6 |                 26   |            81 |                    11.55 |              27.02 |                  4.16 |
| PB               |                      517 |                20.4 |                 33   |            57 |                    11.03 |              48.84 |                  4.08 |
| PE               |                     1593 |                18.4 |                 31.1 |           172 |                    10.8  |              35.83 |                  4.08 |
| RN               |                      474 |                19.3 |                 32.2 |            51 |                    10.76 |              39.26 |                  4.15 |
| SC               |                     3546 |                15   |                 25.8 |           346 |                     9.76 |              24.85 |                  4.13 |
| GO               |                     1957 |                15.6 |                 27.1 |           160 |                     8.18 |              26.25 |                  4.1  |
| RS               |                     5345 |                15.3 |                 28.5 |           382 |                     7.15 |              24.8  |                  4.19 |
| DF               |                     2080 |                13   |                 24.3 |           147 |                     7.07 |              23.86 |                  4.13 |
| MT               |                      886 |                18.1 |                 31.7 |            60 |                     6.77 |              32.77 |                  4.15 |

*... (Showing top 20 rows of 27 total rows returned)*


*(Rows returned: 27)*

---

### Query 56: 08_operations_analysis.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 28: Customer Satisfaction (Review Scores) vs Delivery Performance
-- Business Meaning:
-- Quantifies the relationship between on-time delivery vs late delivery
-- on customer review ratings (1-star vs 5-star shares).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| delivery_punctuality                    |   total_delivered_orders |   avg_actual_delivery_days |   avg_delay_days |   avg_review_score |   five_star_pct |   one_star_pct |
|:----------------------------------------|-------------------------:|---------------------------:|-----------------:|-------------------:|----------------:|---------------:|
| 1. Delivered On-Time or Early           |                    88171 |                       10.9 |            -13   |               4.29 |           62.38 |           6.56 |
| 2. Delivered Late (Past Estimated Date) |                     7661 |                       31.4 |              9.4 |               2.57 |           22.2  |          46.12 |

*(Rows returned: 2)*

---

### Query 57: 08_operations_analysis.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 29: Delivery Delay Magnitude vs Average Review Score
-- Business Meaning:
-- Groups delayed orders into delay buckets to measure rating drop-off.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| delay_severity_bucket             |   order_count |   pct_of_delivered |   avg_review_score |   one_star_rating_pct |
|:----------------------------------|--------------:|-------------------:|-------------------:|----------------------:|
| 0. On-Time / Early                |         88163 |              91.38 |               4.29 |                  6.55 |
| 1. Slight Delay (1-3 days late)   |          2636 |               2.73 |               3.77 |                 13.69 |
| 2. Moderate Delay (4-7 days late) |          1773 |               1.84 |               2.32 |                 53.02 |
| 3. Heavy Delay (8-14 days late)   |          1748 |               1.81 |               1.75 |                 68.02 |
| 4. Severe Delay (15+ days late)   |          1512 |               1.57 |               1.73 |                 69.05 |

*(Rows returned: 5)*

---

### Query 58: 08_operations_analysis.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 30: Cancellation Rate Trends Over Time
-- Business Meaning:
-- Evaluates platform order cancellations by month.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| order_year_month   |   total_orders_placed |   canceled_orders |   cancellation_rate_pct |   canceled_gmv_impact |
|:-------------------|----------------------:|------------------:|------------------------:|----------------------:|
| 2017-01            |                   800 |                 3 |                    0.38 |                368.28 |
| 2017-02            |                  1780 |                17 |                    0.96 |               2827    |
| 2017-03            |                  2682 |                33 |                    1.23 |               7457.23 |
| 2017-04            |                  2404 |                18 |                    0.75 |               7942.02 |
| 2017-05            |                  3700 |                29 |                    0.78 |               4388.86 |
| 2017-06            |                  3245 |                16 |                    0.49 |               3973.76 |
| 2017-07            |                  4026 |                28 |                    0.7  |               7051.56 |
| 2017-08            |                  4331 |                27 |                    0.62 |               7171.85 |
| 2017-09            |                  4285 |                20 |                    0.47 |               3981.18 |
| 2017-10            |                  4631 |                26 |                    0.56 |               6573.53 |
| 2017-11            |                  7544 |                37 |                    0.49 |               7658.44 |
| 2017-12            |                  5673 |                11 |                    0.19 |               3439.25 |
| 2018-01            |                  7269 |                34 |                    0.47 |               5540.18 |
| 2018-02            |                  6728 |                73 |                    1.09 |               7673.15 |
| 2018-03            |                  7211 |                26 |                    0.36 |               3408.36 |
| 2018-04            |                  6939 |                15 |                    0.22 |               3449.15 |
| 2018-05            |                  6873 |                24 |                    0.35 |               4498.38 |
| 2018-06            |                  6167 |                18 |                    0.29 |               2660.48 |
| 2018-07            |                  6292 |                41 |                    0.65 |              19118    |
| 2018-08            |                  6512 |                84 |                    1.29 |              23921.2  |

*(Rows returned: 20)*

---

## Script: `09_advanced_sql.sql`

### Query 59: 09_advanced_sql.sql - Section 1
```text
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
```

```sql
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
```

**Execution Result:**

| order_year_month   |   current_orders |   prev_orders |   mom_order_growth_pct |      current_gmv |         prev_gmv |   mom_gmv_growth_pct |
|:-------------------|-----------------:|--------------:|-----------------------:|-----------------:|-----------------:|---------------------:|
| 2017-01            |              800 |           nan |                 nan    | 120313           |    nan           |               nan    |
| 2017-02            |             1780 |           800 |                 122.5  | 247303           | 120313           |               105.55 |
| 2017-03            |             2682 |          1780 |                  50.67 | 374344           | 247303           |                51.37 |
| 2017-04            |             2404 |          2682 |                 -10.37 | 359927           | 374344           |                -3.85 |
| 2017-05            |             3700 |          2404 |                  53.91 | 506071           | 359927           |                40.6  |
| 2017-06            |             3245 |          3700 |                 -12.3  | 433039           | 506071           |               -14.43 |
| 2017-07            |             4026 |          3245 |                  24.07 | 498031           | 433039           |                15.01 |
| 2017-08            |             4331 |          4026 |                   7.58 | 573972           | 498031           |                15.25 |
| 2017-09            |             4285 |          4331 |                  -1.06 | 624402           | 573972           |                 8.79 |
| 2017-10            |             4631 |          4285 |                   8.07 | 664219           | 624402           |                 6.38 |
| 2017-11            |             7544 |          4631 |                  62.9  |      1.01027e+06 | 664219           |                52.1  |
| 2017-12            |             5673 |          7544 |                 -24.8  | 743914           |      1.01027e+06 |               -26.36 |
| 2018-01            |             7269 |          5673 |                  28.13 | 950030           | 743914           |                27.71 |
| 2018-02            |             6728 |          7269 |                  -7.44 | 844179           | 950030           |               -11.14 |
| 2018-03            |             7211 |          6728 |                   7.18 | 983213           | 844179           |                16.47 |
| 2018-04            |             6939 |          7211 |                  -3.77 | 996648           | 983213           |                 1.37 |
| 2018-05            |             6873 |          6939 |                  -0.95 | 996518           | 996648           |                -0.01 |
| 2018-06            |             6167 |          6873 |                 -10.27 | 865124           | 996518           |               -13.19 |
| 2018-07            |             6292 |          6167 |                   2.03 | 895507           | 865124           |                 3.51 |
| 2018-08            |             6512 |          6292 |                   3.5  | 854686           | 895507           |                -4.56 |

*(Rows returned: 20)*

---

### Query 60: 09_advanced_sql.sql - Section 2
```text
-- --------------------------------------------------------------------
-- QUESTION 32: Cumulative Running Platform GMV using SUM() OVER ()
-- Business Meaning:
-- Tracks enterprise cumulative GMV expansion across the timeline.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| order_year_month   |      monthly_gmv |   cumulative_running_gmv |
|:-------------------|-----------------:|-------------------------:|
| 2017-01            | 120313           |         120313           |
| 2017-02            | 247303           |         367616           |
| 2017-03            | 374344           |         741960           |
| 2017-04            | 359927           |              1.10189e+06 |
| 2017-05            | 506071           |              1.60796e+06 |
| 2017-06            | 433039           |              2.041e+06   |
| 2017-07            | 498031           |              2.53903e+06 |
| 2017-08            | 573972           |              3.113e+06   |
| 2017-09            | 624402           |              3.7374e+06  |
| 2017-10            | 664219           |              4.40162e+06 |
| 2017-11            |      1.01027e+06 |              5.41189e+06 |
| 2017-12            | 743914           |              6.15581e+06 |
| 2018-01            | 950030           |              7.10584e+06 |
| 2018-02            | 844179           |              7.95002e+06 |
| 2018-03            | 983213           |              8.93323e+06 |
| 2018-04            | 996648           |              9.92988e+06 |
| 2018-05            | 996518           |              1.09264e+07 |
| 2018-06            | 865124           |              1.17915e+07 |
| 2018-07            | 895507           |              1.2687e+07  |
| 2018-08            | 854686           |              1.35417e+07 |

*(Rows returned: 20)*

---

### Query 61: 09_advanced_sql.sql - Section 3
```text
-- --------------------------------------------------------------------
-- QUESTION 33: Top 3 Bestselling Products per Category using DENSE_RANK()
-- Business Meaning:
-- Identifies top 3 revenue-generating products within each merchandise category.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| category                   |   rank_in_category | product_id                       |   units_sold |   product_gmv |
|:---------------------------|-------------------:|:---------------------------------|-------------:|--------------:|
| agro_industry_and_commerce |                  1 | 11250b0d4b709fee92441c5f34122aed |           22 |       9111    |
| agro_industry_and_commerce |                  2 | 423a6644f0aa529e8828ff1f91003690 |           18 |       8043    |
| agro_industry_and_commerce |                  3 | 672e757f331900b9deea127a2a7b79fd |           17 |       6885    |
| air_conditioning           |                  1 | 12485f9cdebb6ca179826ede539554ad |            5 |       3899.91 |
| air_conditioning           |                  2 | 83ca77d87b187321faaee535adbce26c |            3 |       2469.85 |
| air_conditioning           |                  3 | 0e34187d4312b97b5e698836d28ed040 |           11 |       2193    |
| art                        |                  1 | 4fe644d766c7566dbc46fb851363cb3b |          107 |      10803.7  |
| art                        |                  2 | 1bdf5e6731585cf01aa8169c7028d6ad |            1 |       6499    |
| art                        |                  3 | cbf96c04205dc933b89e025748c2a057 |            5 |        487.5  |
| arts_and_craftmanship      |                  1 | b9976e9c22fb1540bd71d1bcd2989475 |            5 |        641.45 |
| arts_and_craftmanship      |                  2 | 6bb18295cc019bf3b6dc7c773411d530 |            1 |        289.49 |
| arts_and_craftmanship      |                  3 | 43506d2b6b5e0535079f88c7dc51c4de |            1 |        238    |
| audio                      |                  1 | 13db47eae724e2848e12b71a617a3a41 |           26 |      12992.6  |
| audio                      |                  2 | 9bfc55df037ce3ac01bfd84781adf7e5 |           16 |       9441.94 |
| audio                      |                  3 | db5efde3ad0cc579b130d71c4b2db522 |           48 |       9425.78 |
| auto                       |                  1 | fd0065af7f09af4b82a0ca8f3eed1852 |           11 |      21999.9  |
| auto                       |                  2 | 1dec4c88c685d5a07bf01dcb0f8bf9f8 |           35 |      19965    |
| auto                       |                  3 | f4f67ccaece962d013a4e1d7dc3a61f7 |           56 |      13139.8  |
| baby                       |                  1 | 25c38557cf793876c5abdd5931f922db |           38 |      38907.3  |
| baby                       |                  2 | cac9e5692471a0700418aa3400b9b2b1 |           89 |      10006.9  |

*... (Showing top 20 rows of 30 total rows returned)*


*(Rows returned: 30)*

---

### Query 62: 09_advanced_sql.sql - Section 4
```text
-- --------------------------------------------------------------------
-- QUESTION 34: Customer Pareto Revenue Concentration (80/20 Rule)
-- Business Meaning:
-- Calculates what percentage of total marketplace GMV is driven by the
-- top 20% of customers using window functions.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

|   cust_rank |   customer_percentile_pct |   customer_spend |   cumulative_spend |   cumulative_gmv_share_pct |
|------------:|--------------------------:|-----------------:|-------------------:|---------------------------:|
|           1 |                      0    |         13440    |    13440           |                       0.1  |
|          10 |                      0.01 |          4400    |    67565.6         |                       0.5  |
|         100 |                      0.11 |          2258    |   328455           |                       2.45 |
|        4734 |                      5    |           419.99 |        3.91441e+06 |                      29.14 |
|        9469 |                     10    |           280    |        5.52429e+06 |                      41.12 |
|       18939 |                     20    |           179.9  |        7.6106e+06  |                      56.65 |
|       47348 |                     50    |            89.8  |        1.11944e+07 |                      83.33 |
|       94697 |                    100    |             0    |        1.34338e+07 |                     100    |

*(Rows returned: 8)*

---

### Query 63: 09_advanced_sql.sql - Section 5
```text
-- --------------------------------------------------------------------
-- QUESTION 35: Inter-Purchase Order Velocity using LAG() on Purchase Timestamps
-- Business Meaning:
-- Calculates the average number of days between consecutive orders for
-- repeat customers to evaluate the natural re-order cycle.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

|   repeat_order_events |   avg_days_between_orders |   min_days_between_orders |   max_days_between_orders |
|----------------------:|--------------------------:|--------------------------:|--------------------------:|
|                  3256 |                      79.3 |                         0 |                       609 |

*(Rows returned: 1)*

---

### Query 64: 09_advanced_sql.sql - Section 6
```text
-- --------------------------------------------------------------------
-- QUESTION 36: Monthly Customer Cohort Retention Matrix (2017 Cohorts)
-- Business Meaning:
-- Analyzes monthly cohort retention rates by tracking customer activity
-- across subsequent months (Month 0 to Month 6).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| cohort_month   |   cohort_size |   m0_active |   m1_active |   m2_active |   m3_active |   m4_active |   m5_active |   m6_active |
|:---------------|--------------:|------------:|------------:|------------:|------------:|------------:|------------:|------------:|
| 2017-01        |           743 |         743 |           3 |           2 |           1 |           3 |           1 |           4 |
| 2017-02        |          1663 |        1663 |           4 |           5 |           2 |           7 |           2 |           4 |
| 2017-03        |          2550 |        2550 |          13 |           9 |          10 |           9 |           4 |           4 |
| 2017-04        |          2315 |        2315 |          14 |           5 |           4 |           7 |           6 |           8 |
| 2017-05        |          3523 |        3523 |          17 |          18 |          14 |          11 |          12 |          15 |
| 2017-06        |          3091 |        3091 |          14 |          11 |          13 |           8 |          12 |          11 |

*(Rows returned: 6)*

---

### Query 65: 09_advanced_sql.sql - Section 7
```text
-- --------------------------------------------------------------------
-- QUESTION 37: 3-Month Moving Average of GMV
-- Business Meaning:
-- Smooths monthly revenue seasonality using a 3-month rolling window.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| order_year_month   |      monthly_gmv |   gmv_3month_moving_avg |
|:-------------------|-----------------:|------------------------:|
| 2017-01            | 120313           |                  120313 |
| 2017-02            | 247303           |                  183808 |
| 2017-03            | 374344           |                  247320 |
| 2017-04            | 359927           |                  327192 |
| 2017-05            | 506071           |                  413448 |
| 2017-06            | 433039           |                  433012 |
| 2017-07            | 498031           |                  479047 |
| 2017-08            | 573972           |                  501681 |
| 2017-09            | 624402           |                  565468 |
| 2017-10            | 664219           |                  620864 |
| 2017-11            |      1.01027e+06 |                  766298 |
| 2017-12            | 743914           |                  806135 |
| 2018-01            | 950030           |                  901405 |
| 2018-02            | 844179           |                  846041 |
| 2018-03            | 983213           |                  925808 |
| 2018-04            | 996648           |                  941347 |
| 2018-05            | 996518           |                  992126 |
| 2018-06            | 865124           |                  952763 |
| 2018-07            | 895507           |                  919050 |
| 2018-08            | 854686           |                  871773 |

*(Rows returned: 20)*

---

### Query 66: 09_advanced_sql.sql - Section 8
```text
-- --------------------------------------------------------------------
-- QUESTION 38: Customer Spend Quartiles using NTILE(4)
-- Business Meaning:
-- Segments customer accounts into 4 equal quartiles based on lifetime spend.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

|   spend_quartile |   customer_count |   quartile_total_gmv |   quartile_gmv_share_pct |   min_spend |   max_spend |   avg_spend |
|-----------------:|-----------------:|---------------------:|-------------------------:|------------:|------------:|------------:|
|                1 |            23675 |          8.40429e+06 |                    62.56 |       154.9 |     13440   |      354.99 |
|                2 |            23674 |          2.79017e+06 |                    20.77 |        89.8 |       154.9 |      117.86 |
|                3 |            23674 |          1.55005e+06 |                    11.54 |        47.8 |        89.8 |       65.47 |
|                4 |            23674 |     689245           |                     5.13 |         0   |        47.8 |       29.11 |

*(Rows returned: 4)*

---

### Query 67: 09_advanced_sql.sql - Section 9
```text
-- --------------------------------------------------------------------
-- QUESTION 39: Top 3 Sellers by State using RANK()
-- Business Meaning:
-- Ranks sellers by revenue within their home state.
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| seller_state   |   rank_in_state | seller_id                        | seller_city    |   seller_gmv |
|:---------------|----------------:|:---------------------------------|:---------------|-------------:|
| MG             |               1 | a1043bafd471dff536d0c462352beb48 | ilicinea       |     101901   |
| MG             |               2 | 25c5c91f63607446a97b143d2d535d31 | itauna         |      54679.2 |
| MG             |               3 | 7299e27ed73d2ad986de7f7c77d919fa | araguari       |      34725.4 |
| PR             |               1 | ccc4bbb5f32a6ab2b7066a4130f114e3 | curitiba       |      74004.6 |
| PR             |               2 | 522620dcb18a6b31cd7bdf73665113a9 | cascavel       |      57168.5 |
| PR             |               3 | 77530e9772f57a62c906e1c21538ab82 | curitiba       |      46610.4 |
| RJ             |               1 | 46dc3b2cc0980fb8ec44634e21d2718e | rio de janeiro |     128111   |
| RJ             |               2 | 620c87c171fb2a6dd6e8bb4dec959fc6 | petropolis     |     114774   |
| RJ             |               3 | edb1ef5e36e0c8cd84eb3c9b003e486d | teresopolis    |      79284.6 |
| RS             |               1 | 87142160b41353c4e5fca2360caf6f92 | porto alegre   |      31096   |
| RS             |               2 | b32be1695eb7ec5f10f72d9610a12527 | caxias do sul  |      26874   |
| RS             |               3 | 12b9676b00f60f3b700e83af21824c0e | montenegro     |      26774   |
| SP             |               1 | 4869f7a5dfa277a7dca6462dcf3b52b2 | guariba        |     229473   |
| SP             |               2 | 4a3ca9315b744ce9f8e9374361493884 | ibitinga       |     200473   |
| SP             |               3 | fa1c13f2614d7b5c4749cbc52fecda94 | sumare         |     194042   |

*(Rows returned: 15)*

---

### Query 68: 09_advanced_sql.sql - Section 10
```text
-- --------------------------------------------------------------------
-- QUESTION 40: High-Revenue Products with Substandard Review Scores
-- Business Meaning:
-- Identifies top 10 products with high sales (>= R$ 5,000) that suffer
-- from poor customer satisfaction (average review score < 3.5).
-- --------------------------------------------------------------------
```

```sql
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
```

**Execution Result:**

| product_id                       | category              |   units_sold |   total_gmv |   avg_review_score |   one_star_pct |
|:---------------------------------|:----------------------|-------------:|------------:|-------------------:|---------------:|
| 25c38557cf793876c5abdd5931f922db | baby                  |           37 |     37908.3 |               2.68 |          40.54 |
| fd0065af7f09af4b82a0ca8f3eed1852 | auto                  |           11 |     21999.9 |               1.18 |          90.91 |
| 1dec4c88c685d5a07bf01dcb0f8bf9f8 | auto                  |           34 |     19376   |               2.74 |          38.24 |
| fb01a5fc09b9b9563c2ee41a22f07d54 | consoles_games        |           23 |     16041.9 |               2.87 |          43.48 |
| e53e557d5a159f5aa2c5e995dfdf244b | computers_accessories |          185 |     15647.9 |               3.46 |          27.57 |
| 5769ef0a239114ac3a854af00df129e4 | fixed_telephony       |            8 |     13440   |               1    |         100    |
| 8ed094bfe076c568f6bb10feada3f75d | office_furniture      |           70 |     12947.1 |               3.44 |          20    |
| 44fc450365728c413fefc547592626be | small_appliances      |           15 |     12788   |               3.33 |          26.67 |
| 36f60d45225e60c7da4558b070ce4b60 | computers_accessories |          136 |     11939.2 |               3.29 |          30.88 |
| 2ffdf10e724b958c0f7ea69e97d32f64 | watches_gifts         |           51 |     10692.6 |               3.25 |          29.41 |

*(Rows returned: 10)*

---
