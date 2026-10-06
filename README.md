# Chair Manufacturing BI Portfolio Project

## Overview

This project is based on the kind of BI work I would expect to own at a medium sized manufacturer with operational data but no dependable reporting layer.

Northline Seating is a fictional company. I worked through the project from raw CRM and ERP style exports to cleaned data, QA, SQL analysis, Power BI modeling, DAX, report design, and final validation.

The main goal was simple. I wanted the numbers in the report to be traceable back to the source data and business rules.

## Tools

* Excel and Power Query for data cleanup, transformations, and documentation
* Python and pandas for QA and reconciliation after cleanup
* SQLite and SQL for validation and business analysis
* Power BI and DAX for the model, measures, drillthrough, and reporting
* VS Code for Python and SQL work

## Data

The cleaned analytical layer contains 51,038 rows across seven core tables.

* Accounts: 1,247
* Opportunities: 11,500
* Orders: 6,880
* Order Lines: 29,918
* Returns and RMAs: 850
* Warranty Claims: 600
* Product Reference: 43

The history covers roughly September 2021 through September 2026.

## Business Questions

The report was built to answer questions around:

* Sales pipeline and stale opportunities
* Won sales and sales rep performance
* Account value and weighted account ranking
* Product sales and margin
* Backlog and shipped revenue
* Bookings vs. backlog vs. shipments
* On-time performance and current delayed orders
* Returns and warranty claims
* Lost opportunities and cancelled orders
* Account concentration and repeat business

## Workflow

### 1. Preserve the raw source

The raw exports stay unchanged. Cleanup is done in separate working copies so I can compare the cleaned data back to the original source.

### 2. Clean and document the data

I used Excel and Power Query for data types, duplicate handling, account matching, key creation, ZIP and date formatting, FREIGHT and TAX handling, shipped and backlog logic, and cleanup notes.

I did not guess on ambiguous records. If the source did not give me enough information to make a reliable correction, I left the issue visible.

### 3. Validate with Python

The pandas QA script checks:

* Duplicate and missing keys
* Calculation logic
* Shipped revenue and quantity
* Backlog value and quantity
* Relationships between tables
* Order header to order line reconciliation
* Return and warranty references
* Won opportunity to ERP order handoff
* Warranty replacement order links

Final QA returned zero calculation mismatches, zero order header reconciliation mismatches, and zero invalid cleaned core relationships. Remaining exceptions stayed visible for review.

### 4. Analyze with SQL

I loaded the cleaned files into SQLite and used SQL for both QA and business analysis. The SQL work covers sales, pipeline, stale opportunities, shipped revenue, backlog, margin, rep performance, returns, warranty, on-time performance, lost reasons, cancellations, top accounts, repeat business, and the flow from bookings to backlog to shipments.

### 5. Build the Power BI model

The Power BI model keeps the main business processes separate. Accounts, Date, Product Reference, and Sales Rep are shared dimensions. Opportunities, Orders, Order Lines, Returns, and Warranty stay at their own level of detail.

Important reporting decisions:

* Current Open Pipeline and Current Backlog are current snapshot measures, so they ignore the Date slicer.
* Shipped Revenue is recognized on the order line Ship Date.
* Backlog is the remaining unshipped product line Value on open or partially shipped orders.
* FREIGHT and TAX are excluded from core product quantity, sales, and margin reporting.
* Historical transaction price and COGS are kept instead of being replaced with current Product Reference values.
* The Date table extends through January 2027 so future projected opportunities stay in the model.

## Weighted Account Ranking

Management wanted a way to rank accounts using more than revenue. I built the score with these weights:

* Won Value: 30%
* Average Margin: 20%
* Won Orders: 15%
* Pipeline Value: 15%
* Return Rate: 10%
* Warranty Rate: 10%

Lower return and warranty rates score better.

## Power BI Report Pages

1. Executive Overview
2. Sales Pipeline
3. Lost Opportunities & Cancelled Orders
4. Customer & Rep Performance
5. Sales Rep Workspace
6. Account Ranking
7. Account Concentration & Repeat Business
8. Product & Margin
9. Bookings vs Backlog vs Shipments
10. Backlog & Shipping
11. Delays & Operations
12. Returns & Warranty
13. Account 360, hidden drillthrough page

The Delays & Operations page is a current work queue. It shows open orders with an Adjusted Promised Ship Date and excludes Closed and Cancelled orders.

## Headline Results

* Won Sales: $310.32M
* Shipped Revenue: $283.73M
* Current Open Pipeline: $33.24M
* Current Backlog: $15.13M
* Shipped Margin: 46.27%
* On-time rate: 91.93%
* Returns: 850
* Warranty Claims: 600

## Key Findings

* Won sales reached $75.38M through September 2026. That was already above the $73.19M full year 2025 result.
* Of the $33.24M in current open pipeline, $19.55M was stale, or 58.8%.
* Office Chairs produced about 65.1% of shipped revenue and 74.6% of current backlog.
* Competitor Selected and Price accounted for about 46.8% of lost opportunity value.
* The top 10 accounts represented about 4.4% of shipped revenue. Repeat business among accounts with shipped standard orders was about 87.0%.
* Standard order on-time performance was 91.93%.

## Dashboard Screenshots

The portfolio includes six screenshots that show the main areas of the report:

* Executive Overview
* Sales Pipeline
* Account Ranking
* Product & Margin
* Delays & Operations
* Returns & Warranty

## Repository Structure

The main folders are:

1. `1. Raw Data`
2. `2. Clean Data`
3. `3. Analysis`
4. `4. Power BI`
5. `5. Documentation`
6. `6. Images`
7. `Prep Documents`

The private project material is kept out of the public repository.

## Project Files to Review

For a quick review, I would start with:

1. The case study PDF in `5. Documentation`
2. Dashboard screenshots in `6. Images/Dashboard Screenshots`
3. The Power BI file in `4. Power BI`
4. `Chair_BI_QA.py` and the QA summary in `3. Analysis/Python`
5. The SQL analysis in `3. Analysis/SQL`

## Notes

This is a portfolio project based on a fictional company and simulated CRM and ERP style data. The business rules, cleanup work, QA, SQL analysis, and reporting decisions are included so the project can be reviewed as a complete BI workflow.
