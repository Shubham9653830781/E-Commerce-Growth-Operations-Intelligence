# Dataset Validation & Quality Audit

**Dataset**: Brazilian E-Commerce Public Dataset by Olist  
**Audit Date**: October 2026  
**Scope**: 9 raw CSV files under `data/raw/`  
**Execution**: Verified via automated Python integrity suite (`src/validate_dataset.py`)

---

## 1. File Inventory & Storage Verification

All 9 official files were verified for presence, size, and readability in `data/raw/`:

| File Name | Size (Bytes) | Row Count | Column Count | Primary Key | Key Uniqueness |
|:---|:---:|:---:|:---:|:---|:---:|
| `olist_orders_dataset.csv` | 17,654,914 | 99,441 | 8 | `order_id` | 100% (99,441 unique) |
| `olist_order_items_dataset.csv` | 15,438,671 | 112,650 | 7 | `(order_id, order_item_id)` | 100% unique composite |
| `olist_order_payments_dataset.csv` | 5,777,138 | 103,886 | 5 | `(order_id, payment_sequential)`| 100% unique composite |
| `olist_order_reviews_dataset.csv` | 14,451,670 | 99,224 | 7 | `review_id` | 98,410 unique (re-surveys) |
| `olist_customers_dataset.csv` | 9,033,957 | 99,441 | 5 | `customer_id` | 100% (99,441 unique) |
| `olist_sellers_dataset.csv` | 174,703 | 3,095 | 4 | `seller_id` | 100% (3,095 unique) |
| `olist_products_dataset.csv` | 2,379,446 | 32,951 | 9 | `product_id` | 100% (32,951 unique) |
| `product_category_name_translation.csv` | 2,613 | 71 | 2 | `product_category_name` | 100% (71 unique) |
| `olist_geolocation_dataset.csv` | 61,273,883 | 1,000,163 | 5 | `geolocation_zip_code_prefix` | Zip prefix lookup |

---

## 2. Referential Integrity & Foreign Key Audit

All foreign key relationships were audited for orphaned records:

| Parent Table & Key | Child Table & Key | Child Total Rows | Matched Rows | Orphan Records | Status |
|:---|:---|:---:|:---:|:---:|:---:|
| `customers(customer_id)` | `orders(customer_id)` | 99,441 | 99,441 | **0** | **100% Valid** |
| `orders(order_id)` | `order_items(order_id)` | 112,650 | 112,650 | **0** | **100% Valid** |
| `products(product_id)` | `order_items(product_id)` | 112,650 | 112,650 | **0** | **100% Valid** |
| `sellers(seller_id)` | `order_items(seller_id)` | 112,650 | 112,650 | **0** | **100% Valid** |
| `orders(order_id)` | `order_payments(order_id)`| 103,886 | 103,886 | **0** | **100% Valid** |
| `orders(order_id)` | `order_reviews(order_id)` | 99,224 | 99,224 | **0** | **100% Valid** |

### Orders Without Child Records (Valid Operational Exceptions):
- **Orders without items (775 orders)**:
  - 603 `unavailable`
  - 164 `canceled`
  - 5 `created`
  - 2 `invoiced`
  - 1 `shipped`
  - *Finding*: These are unfulfilled or canceled orders that were aborted before items were picked.
- **Orders without payments (1 order)**:
  - Order `bfbd0f9bdef84302105ad712db648a6c` (delivered in 2016 during beta rollout without digital payment capture).

---

## 3. Date & Operational Timestamp Integrity

Analysis of chronological order progression:
$$\text{Purchase} \longrightarrow \text{Approval} \longrightarrow \text{Carrier Handoff} \longrightarrow \text{Customer Delivery}$$

- **Purchase to Delivery Chronology**: Exactly 0 orders were recorded as delivered before the purchase timestamp.
- **Delivery Days Range**:
  - Minimum: 0.53 days (approx 12 hours)
  - Median: 10.21 days
  - Mean: 12.50 days
  - Maximum: 209.62 days (extreme logistics anomaly)
- **Late Deliveries Audit**:
  - Delivered Orders: 96,478
  - Delivered After Estimated Date: **7,827 orders**
  - **Platform Late Delivery Rate**: **8.11%**

---

## 4. Financial & Numerical Sanity

- **Product Prices (`order_items.price`)**:
  - Range: R$ 0.85 to R$ 6,735.00
  - Zero or Negative Prices: **0 records**
  - Total Product GMV: **R$ 13,591,643.70**
- **Freight Value (`order_items.freight_value`)**:
  - Range: R$ 0.00 to R$ 409.68
  - Free Shipping Items (Freight = 0): 383 items
  - Total Freight Billed: **R$ 2,251,909.54**
  - Total Order Items Value (Price + Freight): **R$ 15,843,553.24**
- **Payment Values (`order_payments.payment_value`)**:
  - Range: R$ 0.00 to R$ 13,664.08
  - Zero Payments: 9 records (voucher credits covering 100% of order value)
  - Total Payments Collected: **R$ 16,008,872.12**
- **Review Scores (`order_reviews.review_score`)**:
  - Integer range: 1 to 5
  - Invalid scores (<1 or >5): **0 records**
  - Mean Score: **4.09 / 5.00**

---

## 5. Granularity & Fan-out Prevention Rules

```
+---------------------------------------------------------------------------------------+
| TABLE                GRAIN                     FAN-OUT RISK     SAFETY RULE           |
+---------------------------------------------------------------------------------------+
| orders               1 row per order           None             Base table            |
| order_items          1 row per item in order   1 to M (up to 21) Aggregate to order   |
|                                                                 before joining!       |
| order_payments       1 row per payment split   1 to M (up to 29) Aggregate to order   |
|                                                                 before joining!       |
| order_reviews        1 row per survey          1 to M (up to 3)  Deduplicate or avg    |
|                                                                 before joining!       |
+---------------------------------------------------------------------------------------+
```

> [!CAUTION]
> Joining `orders` $\bowtie$ `order_items` $\bowtie$ `order_payments` $\bowtie$ `order_reviews` without pre-aggregation produces massive Cartesian fan-out, inflating apparent revenue by over 300%. All SQL models and Power BI measures enforce pre-aggregated dimensional boundaries.
