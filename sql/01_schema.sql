-- ====================================================================
-- E-COMMERCE GROWTH & OPERATIONS INTELLIGENCE
-- SCRIPT 01: DATABASE SCHEMA & INDEX DEFINITIONS
-- Engine: SQLite / MySQL 8.0 Compatible
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- ====================================================================

-- 1. Customers Dimension
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(32) NOT NULL,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INT NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(5) NOT NULL,
    PRIMARY KEY (customer_id)
);

-- 2. Sellers Dimension
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(32) NOT NULL,
    seller_zip_code_prefix INT NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state VARCHAR(5) NOT NULL,
    PRIMARY KEY (seller_id)
);

-- 3. Products Dimension
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

-- 4. Orders Fact Table
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

-- 5. Order Items Granular Line Items Table
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

-- 6. Order Payments Granular Transaction Table
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 7. Order Reviews Satisfaction Table
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

-- 8. Customer RFM Segmentation Table
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

-- Indexes for Query Optimization
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_purchase_date ON orders(order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS idx_orders_year_month ON orders(order_year_month);
CREATE INDEX IF NOT EXISTS idx_customers_unique_id ON customers(customer_unique_id);
CREATE INDEX IF NOT EXISTS idx_customers_state ON customers(customer_state);
CREATE INDEX IF NOT EXISTS idx_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_items_seller_id ON order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_name_english);
CREATE INDEX IF NOT EXISTS idx_sellers_state ON sellers(seller_state);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_reviews_order_id ON order_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_rfm_segment ON customer_rfm(rfm_segment);
