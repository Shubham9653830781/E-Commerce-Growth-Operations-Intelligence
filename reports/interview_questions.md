# Technical & Business Interview Preparation Guide

**Project Title**: E-Commerce Growth & Operations Intelligence  
**Dataset**: Brazilian E-Commerce Public Dataset by Olist (Official Kaggle Release)  
**Verified Financials**: R$ 13.59M GMV | R$ 2.25M Freight | R$ 16.01M Payments | 99,441 Orders | 96,096 Customers

---

### Q1: Why did you choose the Olist dataset?
**Interview Answer:**  
"I chose the Brazilian E-Commerce Public Dataset by Olist because it represents real-world enterprise commerce complexity across 99,441 orders and 112,650 order items from 2016 to 2018. Unlike simplified toy datasets, Olist captures true marketplace multi-table dynamics: multi-item orders, split payment methods, multi-merchant fulfillment, logistics tracking timestamps, and post-purchase customer satisfaction reviews. This allowed me to demonstrate data architecture, anti-fanout SQL engineering, RFM segmentation, cohort retention, and operational delivery analytics."

---

### Q2: What is the grain of the orders table?
**Interview Answer:**  
"The grain of the `orders` table is **one row per individual customer order transaction**, uniquely identified by `order_id` (99,441 unique records). However, child tables have finer grains: `order_items` has a composite grain of `(order_id, order_item_id)` because an order can contain multiple items, and `order_payments` has a grain of `(order_id, payment_sequential)` because an order can be split across multiple payment types."

---

### Q3: Why can't you directly join orders, payments, and order_items and sum everything?
**Interview Answer:**  
"Joining `orders`, `order_items`, and `order_payments` in a single unaggregated query causes **Cartesian join fan-out**. If an order has 3 items and 2 payment splits, joining them produces $3 \times 2 = 6$ rows. If you then run `SUM(price)` or `SUM(payment_value)`, each item's price is duplicated twice and each payment is duplicated three times, artificially inflating revenue metrics by hundreds of percent. To prevent this, I pre-aggregated item totals and payment totals to the `order_id` grain *before* joining into fact tables and BI models."

---

### Q4: What is the difference between customer_id and customer_unique_id?
**Interview Answer:**  
"In Olist, `customer_id` is an order-level transaction token created afresh for each purchase session to maintain privacy and link orders to delivery addresses. In contrast, `customer_unique_id` is the permanent, persistent identifier of the actual human customer across multiple transactions. If you group by `customer_id` to compute repeat customer rates, you will falsely conclude that 100% of customers are one-time buyers. Grouping by `customer_unique_id` reveals that there are 96,096 unique customers, of which **2,997 are repeat buyers (a 3.12% repeat rate)**."

---

### Q5: How did you calculate GMV?
**Interview Answer:**  
"I calculated Gross Merchandise Value (GMV) as the sum of product item selling prices:
$$\text{GMV} = \sum \text{order\_items.price}$$
In SQL: `ROUND(SUM(price), 2)` from `order_items`, resulting in **R$ 13,591,643.70**. I explicitly kept Freight (`R$ 2,251,909.54`) and Payment Surcharges distinct from Product GMV, ensuring that delivery fees and payment financing were never erroneously labeled as product sales."

---

### Q6: How did you calculate AOV (Average Order Value)?
**Interview Answer:**  
"I calculated AOV at the transaction order level by dividing total product GMV by the total count of unique orders:
$$\text{AOV} = \frac{\sum \text{order\_subtotal}}{\text{COUNT(DISTINCT order\_id)}} = \frac{\text{R\$ 13,591,643.70}}{99,441} = \text{R\$ 136.68}$$
If including freight billed to customers, Average Order Total is **R$ 159.32**, and average payment collected per order is **R$ 160.99**."

---

### Q7: How did you calculate RFM?
**Interview Answer:**  
"I performed customer-level RFM modeling using `customer_unique_id` as the identity key:
- **Recency (R)**: Days elapsed between a fixed reference snapshot date (`2018-10-18`, one day post-dataset horizon) and the customer's most recent order timestamp.
- **Frequency (F)**: Total number of valid completed orders placed.
- **Monetary (M)**: Cumulative lifetime product spend (sum of order subtotals).
I scored Recency and Monetary using quintiles (1 to 5). Because 96.9% of customers had 1 order, I used data-driven frequency tiers (1 order = 1, 2 orders = 3, 3 orders = 4, 4+ orders = 5) to segment customers into 8 actionable groups, such as *Champions*, *Loyal Customers*, *At Risk*, and *Lost / Inactive*."

---

### Q8: How did you define a repeat customer?
**Interview Answer:**  
"A repeat customer is defined as any `customer_unique_id` that has completed **strictly more than one order** ($\text{Frequency} > 1$) across the historical dataset. In Olist, there are **2,997 repeat customers out of 96,096 unique buyers**, establishing a baseline repeat customer rate of **3.12%**."

---

### Q9: How did you perform cohort analysis?
**Interview Answer:**  
"I identified each customer's **Cohort Month** as the calendar month of their first purchase (`min(order_purchase_timestamp)` truncated to `YYYY-MM`). For all subsequent orders, I calculated the elapsed month index ($0, 1, 2, \dots, 12$). I then constructed an aggregation matrix measuring the percentage of original cohort members active in each subsequent month. The resulting heatmap showed that 30-day retention drops to **0.3%–0.5%**, providing empirical proof of the platform's high acquisition-dependence."

---

### Q10: How did you calculate delivery delay?
**Interview Answer:**  
"Delivery delay is calculated exclusively for delivered orders by computing the difference between the actual customer delivery timestamp and the estimated delivery timestamp:
$$\text{Delivery Delay Days} = \text{order\_delivered\_customer\_date} - \text{order\_estimated\_delivery\_date}$$
Negative values indicate early delivery (the platform delivered on average **11.54 days ahead of estimate**), while positive values indicate late delivery."

---

### Q11: How did you identify late deliveries?
**Interview Answer:**  
"An order is flagged as late (`is_late = 1`) when `order_status = 'delivered'` and `order_delivered_customer_date > order_estimated_delivery_date`. Across 96,478 delivered orders, exactly **7,826 orders arrived late**, resulting in a platform late delivery rate of **8.11%**."

---

### Q12: How did you analyze seller performance?
**Interview Answer:**  
"I evaluated sellers across volume, financial contribution, and operational reliability:
1. **Volume Tiers**: Grouped sellers into Boutique (1–10 items), Emerging (11–50), Established (51–200), High-Volume (201–500), and Enterprise Anchor (500+ items).
2. **Operational Risk Screening**: Identified 84 high-volume merchants with late delivery rates $>15\%$ or review scores $<3.8$.
3. **Operational Excellence**: Highlighted merchants maintaining $>100$ orders, review scores $\ge 4.2$, and late rates $<5\%$ to serve as benchmark partners."

---

### Q13: What SQL window functions did you use?
**Interview Answer:**  
"I utilized several advanced window functions:
1. **`LAG()`**: Computed Month-over-Month (MoM) GMV and order growth rates, and measured days between consecutive orders for repeat buyers.
2. **`SUM() OVER ()`**: Calculated cumulative running GMV across the multi-year timeline, and running totals for the 80/20 customer Pareto curve.
3. **`DENSE_RANK() OVER (PARTITION BY category ORDER BY sales DESC)`**: Ranked top products within each merchandise category without skipping ranks on ties.
4. **`ROW_NUMBER() OVER (ORDER BY lifetime_spend DESC)`**: Assigned unique sequential ranks to calculate customer percentiles.
5. **`AVG() OVER (ORDER BY year_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`**: Computed 3-month rolling moving averages to smooth seasonality."

---

### Q14: Why did you use CTEs?
**Interview Answer:**  
"I used Common Table Expressions (CTEs) extensively because they break complex, multi-layered business queries into modular, self-documenting stages. For instance, in cohort retention and RFM scoring, intermediate aggregations (like finding each customer's first purchase date) are isolated in readable blocks before being joined to downstream analytics. CTEs eliminate deep subquery nesting and make code maintainable for enterprise data engineering teams."

---

### Q15: How did you validate Power BI numbers?
**Interview Answer:**  
"I established a strict **Three-Tier Cross-Engine Reconciliation** suite. I authored an automated Python audit script (`src/kpi_cross_validation.py`) that queried raw CSVs in pandas, executed SQL queries on `ecommerce_analytics.db`, and compared the outputs against the Power BI DAX definitions. All 12 core metrics (including Total Orders: 99,441; GMV: R$ 13.59M; Late Rate: 8.11%) matched with **zero discrepancy**."

---

### Q16: What was the most important business insight?
**Interview Answer:**  
"The most impactful finding is the **severe sensitivity of customer review ratings to delivery delays**:
- When orders arrive on time or early, the average review score is **4.29 / 5.00**, with **62.8% 5-star ratings** and only 6.8% 1-star ratings.
- When an order arrives late, the average review plunges to **2.26 / 5.00** (-2.03 stars), and **1-star ratings surge 8-fold to 54.3%**.
Delivery delays are the single largest source of customer dissatisfaction and negative brand sentiment on the platform."

---

### Q17: What are the limitations of the dataset?
**Interview Answer:**  
"The primary limitations are:
1. **No Direct Marketing Channels**: Lack of UTM tags, ad spend, and session clickstream data precludes Customer Acquisition Cost (CAC) and channel ROAS calculation.
2. **Missing Cost of Goods Sold (COGS)**: Seller wholesale costs are not captured, meaning we evaluate GMV and freight economics rather than net gross profit.
3. **Static Inventory Data**: The dataset records completed purchases but does not capture out-of-stock events or warehouse inventory turns."

---

### Q18: What would you do with more customer-level data?
**Interview Answer:**  
"With richer customer data—such as web clickstream sessions, app engagement events, email open rates, and return reasons—I would:
1. Build a session conversion funnel to identify where drop-offs occur prior to checkout.
2. Develop personalized product recommendation algorithms based on browsing history.
3. Conduct uplift modeling to identify which at-risk customers respond best to re-engagement incentives."

---

### Q19: How would you improve the analysis?
**Interview Answer:**  
"I would improve the analysis by integrating geospatial distance calculations between seller zip codes and customer zip codes to compute true freight cost efficiency per kilometer. Furthermore, I would apply survival analysis (Kaplan-Meier curves) to model customer churn hazard rates as a function of fulfillment experience."

---

### Q20: What would you predict using machine learning on this dataset?
**Interview Answer:**  
"Three immediate high-value machine learning use cases:
1. **Late Delivery Risk Classifier**: A gradient-boosted tree (XGBoost) predicting whether an order will be delayed at the moment of checkout based on seller location, destination state, product weight, and carrier history.
2. **Customer Churn & Repeat Purchase Classifier**: Predicting whether a first-time buyer will return within 90 days.
3. **Review Rating Regression / Sentiment NLP**: Predicting review scores from customer comment messages and delivery turnaround timestamps."
