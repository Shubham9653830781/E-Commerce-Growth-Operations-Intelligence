import os
import pandas as pd
import numpy as np

raw_dir = r"f:\December\JP\DS_Revision\Project_DA_DS\E-Commerce-Growth-Operations-Intelligence\data\raw"

files = [
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_customers_dataset.csv",
    "olist_sellers_dataset.csv",
    "olist_products_dataset.csv",
    "product_category_name_translation.csv",
    "olist_geolocation_dataset.csv"
]

print("="*80)
print("OLIST DATASET AUDIT")
print("="*80)

summary = []

for f in files:
    path = os.path.join(raw_dir, f)
    # read sample or full
    df = pd.read_csv(path)
    info = {
        "File": f,
        "Rows": len(df),
        "Cols": len(df.columns),
        "Columns": list(df.columns),
        "Null_Columns": {col: int(df[col].isna().sum()) for col in df.columns if df[col].isna().sum() > 0}
    }
    summary.append(info)
    print(f"\n--- {f} ---")
    print(f"Shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    if info["Null_Columns"]:
        print(f"Nulls: {info['Null_Columns']}")
    else:
        print("Nulls: 0 across all columns")
    print(df.head(2))

# Check orders table dates
orders = pd.read_csv(os.path.join(raw_dir, "olist_orders_dataset.csv"))
print("\n--- Orders Order Status Value Counts ---")
print(orders['order_status'].value_counts())
print("\nOrders Date Range:")
print("Min order_purchase_timestamp:", orders['order_purchase_timestamp'].min())
print("Max order_purchase_timestamp:", orders['order_purchase_timestamp'].max())

# Check items table
items = pd.read_csv(os.path.join(raw_dir, "olist_order_items_dataset.csv"))
print("\n--- Order Items Metrics ---")
print("Total Items:", len(items))
print("Unique Orders in Items:", items['order_id'].nunique())
print("Total Item Price Sum:", items['price'].sum())
print("Total Freight Value Sum:", items['freight_value'].sum())
print("Price + Freight Sum:", (items['price'] + items['freight_value']).sum())

# Check payments table
payments = pd.read_csv(os.path.join(raw_dir, "olist_order_payments_dataset.csv"))
print("\n--- Payments Metrics ---")
print("Total Payment Rows:", len(payments))
print("Unique Orders in Payments:", payments['order_id'].nunique())
print("Total Payment Value Sum:", payments['payment_value'].sum())

# Check customers table
customers = pd.read_csv(os.path.join(raw_dir, "olist_customers_dataset.csv"))
print("\n--- Customers Metrics ---")
print("Total customer_id:", len(customers))
print("Unique customer_unique_id:", customers['customer_unique_id'].nunique())
repeat_cust = customers['customer_unique_id'].value_counts()
print(f"Repeat Customers (unique_id count > 1): {(repeat_cust > 1).sum()} ({(repeat_cust > 1).sum() / len(repeat_cust) * 100:.2f}%)")

# Check reviews
reviews = pd.read_csv(os.path.join(raw_dir, "olist_order_reviews_dataset.csv"))
print("\n--- Reviews Metrics ---")
print("Total Review Rows:", len(reviews))
print("Unique Orders in Reviews:", reviews['order_id'].nunique())
print("Average Review Score:", reviews['review_score'].mean())
print("Score distribution:\n", reviews['review_score'].value_counts().sort_index())
