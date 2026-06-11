# supply-Chain-Analysis
# DataCo Supply Chain Analysis | SQL + PostgreSQL

## Problem Statement
DataCo, a global supply chain company operating across 5 markets, 
was experiencing significant operational inefficiencies with no clear 
visibility into root causes. This project investigates late delivery 
patterns, profitability by region and product, customer-level 
performance failures, and the impact of discounting on profit margins 
— all to help leadership make data-driven operational decisions.

## What I Built
End-to-end SQL case study simulating a real analyst investigation:
- Loaded 180,000+ row dataset into PostgreSQL
- Wrote 11 business-driven SQL queries covering delivery performance, 
  revenue analysis, customer segmentation, and discount impact
- Used window functions (DENSE_RANK, LAG) for ranking and 
  month-over-month trend analysis
- Derived actionable business insights from each query result

## Tools Used
- PostgreSQL — querying and analysis
- pgAdmin — database management and query execution
- Excel — raw data preparation and CSV conversion
- GitHub — version control and project documentation

## Key Insights
- 54% of 182,519 orders carry late delivery risk — 1 in 2 orders 
  is at risk of being late, directly damaging customer retention
- Butan and Armenia and Luxemburgo are delivering orders lately
- First Class shipping Mode has highest late deliveries with 95% of deliveries were delivered late
- fishing and cleats brings above 70% profit and atrength training and CD;s are worst profit bringing items and eat place in warehouse
- Either late deliveries and total orders are not improving and performing , overall performance is worst with alomost 50% of deliveries were delivered late 
-they are fluctuating up and low , And 2017 OCTOBER hits major downfall of 50% across all metrics
- discounts and profits are alightly inversly proportional and zero and discounts between 0-10% brings more profits of of 12%

## What I Learnt
- Translating business problems into structured SQL investigations
- Using window functions for ranking and trend analysis in real 
  business context
- Importance of asking the right question before writing any query
- How to present data findings as business insights, not just numbers
- Handling PostgreSQL-specific syntax requirements like ::numeric casting
<img width="1645" height="968" alt="{3EB55F0D-FB4D-4D51-8C27-6185A88161E2}" src="https://github.com/user-attachments/assets/76b8d1d5-b116-48ec-aa76-e52265d2b8a8" />

