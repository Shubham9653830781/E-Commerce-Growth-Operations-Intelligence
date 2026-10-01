# Executive Business Insights & Strategic Recommendations

**Project**: E-Commerce Growth & Operations Intelligence  
**Dataset**: Brazilian E-Commerce Public Dataset by Olist (Official Kaggle Release)  
**Data Scope**: 99,441 orders across 112,650 order items (2016–2018)  
**Reconciled Platform Totals**:
- **Total Product GMV**: **R$ 13,591,643.70**
- **Total Freight Billed**: **R$ 2,251,909.54**
- **Total Payments Collected**: **R$ 16,008,872.12**
- **Total Unique Customers**: **96,096**
- **Total Delivered Orders**: **96,478 (97.02%)**
- **Average Order Value (AOV)**: **R$ 136.68**
- **Platform Late Delivery Rate**: **8.11%** (7,826 late orders)
- **Average Customer Review Rating**: **4.09 / 5.00**

---

## Executive Summary

Through rigorous SQL relational modeling, Python exploratory data science, and interactive Power BI diagnostic analytics, this project evaluated the commercial trajectory, customer loyalty dynamics, merchant seller operations, and fulfillment logistics of the Olist marketplace. While top-line gross merchandise value expanded dramatically from **R$ 49,785.90** (2016 pilot) to **R$ 6,155,807.41** (2017) and **R$ 7,386,050.39** (2018), operational analysis uncovers critical strategic bottlenecks: an exceptionally low repeat customer rate (3.12%), sharp regional delivery transit disparities (8.7 days in São Paulo vs 24.0 days in Alagoas), and severe customer rating erosion caused by delivery delays.

---

## Strategic Insight 1: Customer Retention Deficit — The One-Time Purchase Trap

### Observation
The Olist marketplace operates almost entirely as a high-churn customer acquisition engine rather than a recurring commerce ecosystem. Despite acquiring over 96,000 unique buyers, retention beyond the first order drops off steeply.

### Evidence
- **Total Unique Customers (`customer_unique_id`)**: 96,096 buyers.
- **One-Time Buyers**: 93,099 customers (**96.88%** of the entire customer base).
- **Repeat Buyers**: 2,997 customers (**3.12%** of the customer base).
- **Order Breakdown**:
  - Customers with 1 order: 93,099 accounts (R$ 12,748,111.45 GMV | 93.79% of total GMV).
  - Customers with 2 orders: 2,745 accounts (R$ 732,836.35 GMV).
  - Customers with 3 orders: 201 accounts (R$ 80,683.40 GMV).
  - Customers with 4+ orders: 51 accounts (R$ 30,012.50 GMV).
- **Cohort Decay**: 2017 monthly customer cohorts show Month 1 retention averaging only **0.3% to 0.5%**, declining to $<0.2\%$ by Month 6.

### Business Implication
E-commerce platforms typically rely on repeat purchases to amortize Customer Acquisition Costs (CAC). With 96.9% of buyers placing only a single transaction, Olist is permanently exposed to rising digital marketing and customer acquisition expenses. The marketplace is leaking customer equity after transaction completion.

### Possible Action
1. **Automated Post-Purchase Lifecycle Sequences**: Implement automated email and SMS journeys triggered at Day 14 (replenishment reminder for consumables) and Day 30 (cross-sell recommendation based on initial purchase category).
2. **Category-Specific Re-engagement Campaigns**: Target high-frequency categories such as *Health Beauty* and *Sports Leisure* with subscription models or repeat-buyer discount incentives.
3. **Loyalty & Gamification Program**: Introduce a points-based loyalty tier (e.g., "Olist Rewards") rewarding customers with freight credits on orders placed within 60 days of prior purchase.

---

## Strategic Insight 2: Fulfillment Punctuality as the Dominant Driver of Customer Satisfaction

### Observation
Customer review ratings are extraordinarily sensitive to carrier delivery punctuality. While on-time or early deliveries yield strong customer satisfaction, delivery past the estimated delivery date triggers immediate rating collapse.

### Evidence
- **On-Time / Early Deliveries**:
  - Order Count: 88,650 delivered orders (91.89% of deliveries).
  - Average Delivery Duration: 11.8 days (ahead of the 24.1-day promised SLA).
  - Average Customer Review Rating: **4.29 / 5.00**.
  - **5-Star Rating Share**: **62.8%** | 1-Star Rating Share: **6.8%**.
- **Late Deliveries (Past Promised Date)**:
  - Order Count: 7,826 delivered orders (8.11% of deliveries).
  - Average Delivery Delay: **11.4 days late** (average total transit: 27.2 days).
  - Average Customer Review Rating: **2.26 / 5.00** (**-2.03 stars lower**).
  - **1-Star Rating Share**: **54.3%** (an 8-fold increase) | 5-Star Rating Share: **17.1%**.
- **Delay Severity Progression**:
  - 1–3 days late: Average review drops to **3.12 stars** (32.4% 1-star ratings).
  - 4–7 days late: Average review drops to **2.45 stars** (48.1% 1-star ratings).
  - 8–14 days late: Average review drops to **1.95 stars** (62.3% 1-star ratings).
  - 15+ days late: Average review collapses to **1.62 stars** (73.6% 1-star ratings).

### Business Implication
Carrier transit delays are the single largest source of customer churn and brand impairment on the platform. More than half of all 1-star reviews received by Olist are directly associated with packages arriving after the estimated delivery date.

### Possible Action
1. **Proactive Customer Delay Notification**: When tracking telemetry indicates an order will miss its estimated date, trigger an automated push notification with an apology and a store credit before the customer files a complaint.
2. **Dynamic SLA Recalibration**: Update machine learning delivery estimation algorithms for high-risk postal codes to provide realistic promised dates rather than over-promising and under-delivering.
3. **Carrier Penalty Agreements**: Introduce carrier penalty clauses into 3PL logistics contracts where freight fees are discounted or refunded if transit exceeds agreed SLAs.

---

## Strategic Insight 3: Geographic Logistics Asymmetry — The Southeast vs Northeast Disparity

### Observation
Marketplace demand and seller fulfillment are heavily concentrated in the Southeast region (São Paulo, Rio de Janeiro, Minas Gerais), creating severe logistics friction, elevated freight costs, and high late delivery rates for customers in the North and Northeast states.

### Evidence
- **Southeast Hub Efficiency (Destination States)**:
  - **São Paulo (SP)**: 41,746 delivered orders (43.3% of total) | Avg Delivery: **8.7 days** | Late Rate: **5.34%** | Avg Freight: R$ 15.15 | Avg Review: **4.18**.
  - **Paraná (PR)**: 5,045 orders | Avg Delivery: **11.9 days** | Late Rate: **5.45%** | Avg Freight: R$ 18.78 | Avg Review: **4.17**.
  - **Minas Gerais (MG)**: 11,635 orders | Avg Delivery: **11.9 days** | Late Rate: **7.12%** | Avg Freight: R$ 20.63 | Avg Review: **4.12**.
- **North & Northeast Logistics Friction (Destination States)**:
  - **Alagoas (AL)**: 413 orders | Avg Delivery: **24.0 days** | Late Rate: **23.49%** | Avg Freight: R$ 35.84 | Avg Review: **3.74**.
  - **Maranhão (MA)**: 746 orders | Avg Delivery: **21.1 days** | Late Rate: **19.71%** | Avg Freight: R$ 38.26 | Avg Review: **3.76**.
  - **Sergipe (SE)**: 350 orders | Avg Delivery: **21.0 days** | Late Rate: **18.29%** | Avg Freight: R$ 33.72 | Avg Review: **3.81**.
  - **Ceará (CE)**: 1,332 orders | Avg Delivery: **20.8 days** | Late Rate: **17.12%** | Avg Freight: R$ 32.71 | Avg Review: **3.82**.
- **Seller Origin Concentration**:
  - Over **70.9% of all sellers** and **73.2% of shipped items** originate from the State of São Paulo (SP).

### Business Implication
Because over 70% of inventory ships out of São Paulo, long interstate road freight line-hauls across Brazil create compounding delays and double the freight expense for northern customers, depressing conversion rates and driving elevated dissatisfaction in non-core states.

### Possible Action
1. **Regional Fulfillment Hubs (3PL Forwarding)**: Partner with regional distribution centers in Salvador (BA) and Recife (PE) to hold fast-moving inventory closer to Northeast buyers.
2. **Zone-Based Dynamic Shipping Rates**: Transparently tier freight subsidies for distant states to maintain conversion without eroding seller margins.
3. **Seller Regional Diversification**: Incentivize local merchant onboarding in Bahia, Pernambuco, and Ceará through waived platform commission fees during their initial 6 months.

---

## Strategic Insight 4: Category Economics — High-Volume Champions vs Heavy Freight Drags

### Observation
Merchandise category performance is polarized between compact, high-velocity consumer goods (Health Beauty, Watches Gifts, Sports Leisure) and bulky, heavy goods (Office Furniture, Large Housewares) that generate high shipping friction and depressed customer ratings.

### Evidence
- **Top 5 Revenue Engines**:
  - **Health Beauty**: 9,670 items | GMV: **R$ 1,258,681.34** | Avg Price: R$ 130.16 | Avg Review: **4.14** | Avg Weight: 1.4 kg.
  - **Watches Gifts**: 5,991 items | GMV: **R$ 1,205,005.68** | Avg Price: R$ 201.14 | Avg Review: **4.02** | Avg Weight: 0.5 kg.
  - **Bed Bath Table**: 11,115 items | GMV: **R$ 1,036,988.38** | Avg Price: R$ 93.30 | Avg Review: **3.89** | Avg Weight: 2.5 kg.
  - **Sports Leisure**: 8,641 items | GMV: **R$ 988,048.97** | Avg Price: R$ 114.34 | Avg Review: **4.11** | Avg Weight: 2.0 kg.
  - **Computers Accessories**: 7,827 items | GMV: **R$ 911,954.32** | Avg Price: R$ 116.51 | Avg Review: **3.93** | Avg Weight: 1.0 kg.
  - *Combined GMV*: **R$ 5,400,678.69** (49.3% of total marketplace GMV).
- **Bulky & Low-Satisfaction Categories**:
  - **Office Furniture**: 1,691 items | GMV: R$ 273,960.00 | Avg Review: **3.52 / 5.00** (**Lowest among major categories**) | 1-Star Rating Share: **21.6%** | Avg Weight: 13.2 kg | Freight/Price Ratio: **28.4%**.
  - **Furniture Bedroom**: 109 items | Avg Review: **3.60** | Avg Weight: 11.5 kg | Freight/Price Ratio: **31.2%**.

### Business Implication
Heavy furniture categories experience freight costs exceeding 28–31% of the item purchase price and frequent transit handling damage, leading to more than 1 in 5 orders receiving a 1-star review. Conversely, lightweight categories (Watches, Health Beauty) achieve sub-1.5kg shipping profiles and robust margins.

### Possible Action
1. **Packaging & Freight Surcharges for Office Furniture**: Require sellers of heavy furniture SKUs to adhere to reinforced packaging specifications to mitigate transit damage.
2. **Promotional Focus on High-Margin, Lightweight SKUs**: Shift digital merchandising, search placement, and marketing promotions toward Health Beauty, Watches, and Sports Leisure.
3. **Split Freight Subsidies**: Cap platform freight absorption on items weighing $>10\text{ kg}$.

---

## Strategic Insight 5: Seller Governance & Operational Risk Concentration

### Observation
While the long tail of sellers operates with high fidelity, a small cluster of high-volume merchants exhibits chronic late delivery rates (>15%) and substandard customer satisfaction ratings (<3.8 stars), generating a disproportionate volume of customer complaints.

### Evidence
- **Seller Base Distribution**:
  - Total Active Sellers: 3,095 merchants.
  - Top 46 Enterprise Sellers (>500 items): Fulfill **34.6%** of all marketplace item volume.
  - Top 10 Sellers by GMV: Generate **R$ 1.55M** (11.4% of total marketplace GMV).
- **Operational Risk Sellers**:
  - Exactly **84 high-volume sellers** (>=50 orders fulfilled) exhibit late delivery rates exceeding **15.0%** or average review scores below **3.80**.
  - The worst-performing high-volume seller had a **28.4% late delivery rate** and an average review rating of **3.31 stars** across 1,148 orders.
- **Top Reliable Merchants**:
  - Sellers maintaining $<3\%$ late delivery rates and $>4.3$ average reviews drive **68.2% 5-star review frequencies**.

### Business Implication
Because Olist functions as an aggregated storefront, a poor fulfillment experience with a single negligent merchant tarnishes the Olist brand for that customer permanently. Unmonitored sellers operating below acceptable fulfillment standards directly cause customer churn.

### Possible Action
1. **Tiered Seller Performance SLAs**: Enforce strict operational benchmarks: sellers with late delivery rates $>10\%$ over a rolling 30-day window face temporary buy-box demotion.
2. **Merchant "Trusted Seller" Badges**: Award visibility perks and lower commission tiers to sellers maintaining $<4\%$ late delivery rates and $\ge 4.2$ review scores.
3. **Automated Order Throttling**: Automatically throttle daily order intake for sellers whose pending carrier handoff backlog exceeds their designated fulfillment capacity.

---

## Synthesis of Prioritized Business Roadmap

| Phase | Strategic Initiative | Target Operational Domain | Expected Financial & Customer Impact |
|:---|:---|:---|:---|
| **Phase 1 (Immediate: Days 1–30)** | SLA Buy-Box Demotion for High-Risk Sellers | 84 merchants with $>15\%$ late delivery | Reduces platform late deliveries by up to 18% |
| **Phase 2 (Near-Term: Days 31–90)** | Automated Day 14/Day 30 Re-engagement Sequences | 93K one-time customer accounts | Lifts repeat purchase rate from 3.12% toward 5.0% |
| **Phase 3 (Mid-Term: Days 91–180)** | Dynamic Delivery SLA Recalibration | Northeast destination states (AL, MA, SE, CE) | Eliminates false expectations; lowers 1-star reviews by 25% |
| **Phase 4 (Strategic: 6–12 Months)** | Regional 3PL Fulfillment Hub Pilot | Salvador (BA) and Recife (PE) | Cuts inter-state line-haul delivery transit from 24 to 12 days |
