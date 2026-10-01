import os
import sqlite3
import pandas as pd
import numpy as np

def run_pipeline():
    print("=" * 80)
    print("STARTING E-COMMERCE DATA PROCESSING & ENGINEERING PIPELINE")
    print("=" * 80)

    raw_dir = r"f:\December\JP\DS_Revision\Project_DA_DS\E-Commerce-Growth-Operations-Intelligence\data\raw"
    proc_dir = r"f:\December\JP\DS_Revision\Project_DA_DS\E-Commerce-Growth-Operations-Intelligence\data\processed"
    os.makedirs(proc_dir, exist_ok=True)
    db_path = os.path.join(proc_dir, "ecommerce_analytics.db")

    # 1. Ingest raw datasets
    print("\n[1/7] Ingesting raw datasets...")
    orders = pd.read_csv(os.path.join(raw_dir, "olist_orders_dataset.csv"))
    items = pd.read_csv(os.path.join(raw_dir, "olist_order_items_dataset.csv"))
    payments = pd.read_csv(os.path.join(raw_dir, "olist_order_payments_dataset.csv"))
    reviews = pd.read_csv(os.path.join(raw_dir, "olist_order_reviews_dataset.csv"))
    customers = pd.read_csv(os.path.join(raw_dir, "olist_customers_dataset.csv"))
    sellers = pd.read_csv(os.path.join(raw_dir, "olist_sellers_dataset.csv"))
    products = pd.read_csv(os.path.join(raw_dir, "olist_products_dataset.csv"))
    trans = pd.read_csv(os.path.join(raw_dir, "product_category_name_translation.csv"))

    # 2. Product Category Translation & Enrichment
    print("\n[2/7] Translating and enriching products...")
    cat_trans_map = dict(zip(trans['product_category_name'], trans['product_category_name_english']))
    cat_trans_map['pc_gamer'] = 'pc_gamer'
    cat_trans_map['portateis_cozinha_e_preparadores_de_alimentos'] = 'kitchen_portable_appliances'

    products['category_name_english'] = products['product_category_name'].map(cat_trans_map).fillna('unclassified')
    products['product_weight_kg'] = products['product_weight_g'] / 1000.0
    products['product_volume_cm3'] = products['product_length_cm'] * products['product_height_cm'] * products['product_width_cm']

    # 3. Process Order Timestamps and Operational Metrics
    print("\n[3/7] Processing orders and calculating operational turnaround metrics...")
    time_cols = [
        'order_purchase_timestamp', 'order_approved_at',
        'order_delivered_carrier_date', 'order_delivered_customer_date',
        'order_estimated_delivery_date'
    ]
    for col in time_cols:
        orders[col] = pd.to_datetime(orders[col])

    # Operational durations (in days or hours)
    orders['approval_time_hours'] = (orders['order_approved_at'] - orders['order_purchase_timestamp']).dt.total_seconds() / 3600.0
    orders['carrier_delivery_days'] = (orders['order_delivered_carrier_date'] - orders['order_approved_at']).dt.total_seconds() / 86400.0
    orders['actual_delivery_days'] = (orders['order_delivered_customer_date'] - orders['order_purchase_timestamp']).dt.total_seconds() / 86400.0
    orders['estimated_delivery_days'] = (orders['order_estimated_delivery_date'] - orders['order_purchase_timestamp']).dt.total_seconds() / 86400.0
    orders['delivery_delay_days'] = (orders['order_delivered_customer_date'] - orders['order_estimated_delivery_date']).dt.total_seconds() / 86400.0

    # Operational status flags
    orders['is_delivered'] = (orders['order_status'] == 'delivered').astype(int)
    orders['is_canceled'] = (orders['order_status'] == 'canceled').astype(int)
    orders['is_late'] = (
        (orders['order_delivered_customer_date'].notna()) &
        (orders['order_delivered_customer_date'] > orders['order_estimated_delivery_date'])
    ).astype(int)

    # Temporal dimensions
    orders['order_year'] = orders['order_purchase_timestamp'].dt.year
    orders['order_month'] = orders['order_purchase_timestamp'].dt.month
    orders['order_year_month'] = orders['order_purchase_timestamp'].dt.strftime('%Y-%m')
    orders['order_day_name'] = orders['order_purchase_timestamp'].dt.day_name()
    orders['order_hour'] = orders['order_purchase_timestamp'].dt.hour

    # 4. Pre-Aggregate Order-Level Financials to Prevent Fan-Out
    print("\n[4/7] Pre-aggregating order financials to strictly avoid join fan-out...")
    # Items aggregated to order grain
    order_items_agg = items.groupby('order_id').agg(
        total_items=('order_item_id', 'count'),
        distinct_products=('product_id', 'nunique'),
        distinct_sellers=('seller_id', 'nunique'),
        order_subtotal=('price', 'sum'),
        order_freight=('freight_value', 'sum')
    ).reset_index()
    order_items_agg['order_total_value'] = order_items_agg['order_subtotal'] + order_items_agg['order_freight']

    # Payments aggregated to order grain
    def get_primary_payment(s):
        counts = s.value_counts()
        return counts.index[0] if len(counts) > 0 else 'unknown'

    order_payments_agg = payments.groupby('order_id').agg(
        payment_installments_max=('payment_installments', 'max'),
        payment_type_primary=('payment_type', get_primary_payment),
        payment_splits_count=('payment_sequential', 'max'),
        total_payment_value=('payment_value', 'sum')
    ).reset_index()

    # Reviews aggregated to order grain
    order_reviews_agg = reviews.groupby('order_id').agg(
        review_score=('review_score', 'mean'),
        has_review_comment=('review_comment_message', lambda s: int(s.notna().any()))
    ).reset_index()
    order_reviews_agg['review_score'] = order_reviews_agg['review_score'].round(2)

    # Merge aggregates into clean_orders
    clean_orders = orders.merge(order_items_agg, on='order_id', how='left')
    clean_orders = clean_orders.merge(order_payments_agg, on='order_id', how='left')
    clean_orders = clean_orders.merge(order_reviews_agg, on='order_id', how='left')

    # Fill unfulfilled orders with 0 for financial values
    clean_orders['total_items'] = clean_orders['total_items'].fillna(0).astype(int)
    clean_orders['order_subtotal'] = clean_orders['order_subtotal'].fillna(0.0).round(2)
    clean_orders['order_freight'] = clean_orders['order_freight'].fillna(0.0).round(2)
    clean_orders['order_total_value'] = clean_orders['order_total_value'].fillna(0.0).round(2)
    clean_orders['total_payment_value'] = clean_orders['total_payment_value'].fillna(0.0).round(2)

    # 5. Customer Intelligence, RFM, and Cohort Modeling
    print("\n[5/7] Computing Customer Intelligence, RFM, and Cohort retention...")
    # Link customer_unique_id to orders
    cust_orders = clean_orders.merge(
        customers[['customer_id', 'customer_unique_id', 'customer_state', 'customer_city']],
        on='customer_id',
        how='inner'
    )

    # Calculate Customer First Purchase Month (Cohort)
    cust_first_order = cust_orders[cust_orders['order_status'] != 'canceled'].groupby('customer_unique_id').agg(
        first_purchase_date=('order_purchase_timestamp', 'min')
    ).reset_index()
    cust_first_order['cohort_month'] = cust_first_order['first_purchase_date'].dt.strftime('%Y-%m')

    # RFM metrics per customer_unique_id
    # Reference snapshot date: 2018-10-18 (day after latest order in dataset)
    snapshot_date = cust_orders['order_purchase_timestamp'].max() + pd.Timedelta(days=1)
    
    # Use delivered or valid orders for RFM
    valid_orders = cust_orders[cust_orders['order_status'].isin(['delivered', 'shipped', 'invoiced'])]
    
    rfm = valid_orders.groupby('customer_unique_id').agg(
        recency_days=('order_purchase_timestamp', lambda d: (snapshot_date - d.max()).days),
        frequency=('order_id', 'nunique'),
        monetary=('order_subtotal', 'sum'),
        total_spend_with_freight=('order_total_value', 'sum'),
        customer_city=('customer_city', 'first'),
        customer_state=('customer_state', 'first'),
        first_order_date=('order_purchase_timestamp', 'min'),
        last_order_date=('order_purchase_timestamp', 'max')
    ).reset_index()

    # Join cohort month
    rfm = rfm.merge(cust_first_order[['customer_unique_id', 'cohort_month']], on='customer_unique_id', how='left')

    # RFM Scoring
    # Recency score: Quintiles 1 to 5 (5 is most recent)
    rfm['r_score'] = pd.qcut(rfm['recency_days'], q=5, labels=[5, 4, 3, 2, 1]).astype(int)
    
    # Frequency score: In Olist, 97% of customers have 1 order, so rank based on thresholds
    def assign_f_score(freq):
        if freq == 1:
            return 1
        elif freq == 2:
            return 3
        elif freq == 3:
            return 4
        else:
            return 5
    rfm['f_score'] = rfm['frequency'].apply(assign_f_score)

    # Monetary score: Quintiles 1 to 5 (5 is highest spend)
    rfm['m_score'] = pd.qcut(rfm['monetary'], q=5, labels=[1, 2, 3, 4, 5]).astype(int)

    # Composite RFM Score
    rfm['rfm_score'] = rfm['r_score'].astype(str) + rfm['f_score'].astype(str) + rfm['m_score'].astype(str)

    # RFM Segmentation mapping
    def assign_rfm_segment(row):
        r = row['r_score']
        f = row['f_score']
        m = row['m_score']
        
        if r >= 4 and f >= 3:
            return 'Champions'
        elif r >= 3 and f >= 3:
            return 'Loyal Customers'
        elif r >= 4 and f == 1:
            return 'Recent New Buyers'
        elif r == 3 and f == 1:
            return 'Promising Regulars'
        elif r == 2 and f >= 2:
            return 'At Risk'
        elif r == 1 and f >= 2:
            return 'Cant Lose Them'
        elif r <= 2 and f == 1 and m >= 4:
            return 'Hibernating High Spenders'
        else:
            return 'Lost / Inactive'

    rfm['rfm_segment'] = rfm.apply(assign_rfm_segment, axis=1)

    # 6. Save Processed Clean CSVs
    print("\n[6/7] Exporting processed datasets to CSV...")
    clean_orders.to_csv(os.path.join(proc_dir, "clean_orders.csv"), index=False)
    products.to_csv(os.path.join(proc_dir, "clean_products.csv"), index=False)
    customers.to_csv(os.path.join(proc_dir, "clean_customers.csv"), index=False)
    sellers.to_csv(os.path.join(proc_dir, "clean_sellers.csv"), index=False)
    items.to_csv(os.path.join(proc_dir, "clean_order_items.csv"), index=False)
    payments.to_csv(os.path.join(proc_dir, "clean_order_payments.csv"), index=False)
    reviews.to_csv(os.path.join(proc_dir, "clean_order_reviews.csv"), index=False)
    rfm.to_csv(os.path.join(proc_dir, "customer_rfm.csv"), index=False)

    # 7. Seed Relational SQLite Database with Indexes
    print("\n[7/7] Seeding relational SQLite database and creating B-tree indexes...")
    if os.path.exists(db_path):
        os.remove(db_path)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # Format timestamp strings for SQLite compatibility
    clean_orders_sql = clean_orders.copy()
    for col in time_cols:
        clean_orders_sql[col] = clean_orders_sql[col].dt.strftime('%Y-%m-%d %H:%M:%S')

    clean_orders_sql.to_sql('orders', conn, index=False)
    customers.to_sql('customers', conn, index=False)
    sellers.to_sql('sellers', conn, index=False)
    products.to_sql('products', conn, index=False)
    items.to_sql('order_items', conn, index=False)
    payments.to_sql('order_payments', conn, index=False)
    reviews.to_sql('order_reviews', conn, index=False)
    rfm.to_sql('customer_rfm', conn, index=False)

    # Create Indexes
    indexes = [
        "CREATE INDEX idx_orders_customer_id ON orders(customer_id);",
        "CREATE INDEX idx_orders_status ON orders(order_status);",
        "CREATE INDEX idx_orders_purchase_date ON orders(order_purchase_timestamp);",
        "CREATE INDEX idx_orders_year_month ON orders(order_year_month);",
        "CREATE INDEX idx_customers_unique_id ON customers(customer_unique_id);",
        "CREATE INDEX idx_customers_state ON customers(customer_state);",
        "CREATE INDEX idx_items_order_id ON order_items(order_id);",
        "CREATE INDEX idx_items_product_id ON order_items(product_id);",
        "CREATE INDEX idx_items_seller_id ON order_items(seller_id);",
        "CREATE INDEX idx_products_category ON products(category_name_english);",
        "CREATE INDEX idx_sellers_state ON sellers(seller_state);",
        "CREATE INDEX idx_payments_order_id ON order_payments(order_id);",
        "CREATE INDEX idx_reviews_order_id ON order_reviews(order_id);",
        "CREATE INDEX idx_rfm_segment ON customer_rfm(rfm_segment);"
    ]
    for idx_sql in indexes:
        cur.execute(idx_sql)
    conn.commit()
    conn.close()

    print("\n" + "=" * 80)
    print("PIPELINE COMPLETED SUCCESSFULLY!")
    print(f"Database created at: {db_path}")
    print(f"Database size: {os.path.getsize(db_path):,} bytes")
    print("=" * 80)

if __name__ == "__main__":
    run_pipeline()
