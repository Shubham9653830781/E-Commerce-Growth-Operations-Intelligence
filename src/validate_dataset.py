import os
import pandas as pd
import numpy as np

raw_dir = r"f:\December\JP\DS_Revision\Project_DA_DS\E-Commerce-Growth-Operations-Intelligence\data\raw"

orders = pd.read_csv(os.path.join(raw_dir, "olist_orders_dataset.csv"))
items = pd.read_csv(os.path.join(raw_dir, "olist_order_items_dataset.csv"))
payments = pd.read_csv(os.path.join(raw_dir, "olist_order_payments_dataset.csv"))
reviews = pd.read_csv(os.path.join(raw_dir, "olist_order_reviews_dataset.csv"))
customers = pd.read_csv(os.path.join(raw_dir, "olist_customers_dataset.csv"))
sellers = pd.read_csv(os.path.join(raw_dir, "olist_sellers_dataset.csv"))
products = pd.read_csv(os.path.join(raw_dir, "olist_products_dataset.csv"))
trans = pd.read_csv(os.path.join(raw_dir, "product_category_name_translation.csv"))

print("=== REFERENTIAL INTEGRITY AUDIT ===")
# Orders to Customers
orphaned_orders_cust = (~orders['customer_id'].isin(customers['customer_id'])).sum()
print("Orphaned orders without customer:", orphaned_orders_cust)

# Items to Orders
orphaned_items_order = (~items['order_id'].isin(orders['order_id'])).sum()
print("Orphaned items without order:", orphaned_items_order)

# Items to Products
orphaned_items_prod = (~items['product_id'].isin(products['product_id'])).sum()
print("Orphaned items without product:", orphaned_items_prod)

# Items to Sellers
orphaned_items_seller = (~items['seller_id'].isin(sellers['seller_id'])).sum()
print("Orphaned items without seller:", orphaned_items_seller)

# Payments to Orders
orphaned_payments_order = (~payments['order_id'].isin(orders['order_id'])).sum()
print("Orphaned payments without order:", orphaned_payments_order)

# Reviews to Orders
orphaned_reviews_order = (~reviews['order_id'].isin(orders['order_id'])).sum()
print("Orphaned reviews without order:", orphaned_reviews_order)

# Orders without items
orders_without_items = (~orders['order_id'].isin(items['order_id'])).sum()
print("Orders without items:", orders_without_items, f"(Status breakdown: {orders[~orders['order_id'].isin(items['order_id'])]['order_status'].value_counts().to_dict()})")

# Orders without payments
orders_without_payments = (~orders['order_id'].isin(payments['order_id'])).sum()
print("Orders without payments:", orders_without_payments)

print("\n=== DATE INTEGRITY AUDIT ===")
# Date parsing
date_cols = ['order_purchase_timestamp', 'order_approved_at', 'order_delivered_carrier_date', 'order_delivered_customer_date', 'order_estimated_delivery_date']
for col in date_cols:
    orders[col] = pd.to_datetime(orders[col])

# Check chronological delivery: delivered before purchase?
delivered_orders = orders[orders['order_delivered_customer_date'].notna()]
anomalous_delivery = (delivered_orders['order_delivered_customer_date'] < delivered_orders['order_purchase_timestamp']).sum()
print("Delivered before purchase anomalies:", anomalous_delivery)

# Check carrier before approval?
carrier_orders = orders[orders['order_delivered_carrier_date'].notna() & orders['order_approved_at'].notna()]
anomalous_carrier = (carrier_orders['order_delivered_carrier_date'] < carrier_orders['order_approved_at']).sum()
print("Carrier handoff before order approval anomalies:", anomalous_carrier)

# Delivery delays
late_orders = (delivered_orders['order_delivered_customer_date'] > delivered_orders['order_estimated_delivery_date']).sum()
print(f"Late delivered orders: {late_orders} ({late_orders / len(delivered_orders) * 100:.2f}%)")

print("\n=== FINANCIAL INTEGRITY AUDIT ===")
print("Min price:", items['price'].min(), "Max price:", items['price'].max(), "Zero/Negative price count:", (items['price'] <= 0).sum())
print("Min freight:", items['freight_value'].min(), "Max freight:", items['freight_value'].max(), "Zero freight count:", (items['freight_value'] == 0).sum())
print("Min payment:", payments['payment_value'].min(), "Max payment:", payments['payment_value'].max(), "Zero payment count:", (payments['payment_value'] == 0).sum())

print("\n=== CATEGORY TRANSLATION AUDIT ===")
prod_cats = products['product_category_name'].dropna().unique()
translated_cats = trans['product_category_name'].unique()
missing_trans = set(prod_cats) - set(translated_cats)
print("Product categories missing translation:", len(missing_trans), missing_trans)
missing_cat_items = items[items['product_id'].isin(products[products['product_category_name'].isna()]['product_id'])]
print("Items with missing product category:", len(missing_cat_items))
