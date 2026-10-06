import pandas as pd


# -----------------------------
# LOAD ORDER LINES
# -----------------------------

order_lines = pd.read_excel(
    "../../2. Clean Data/Order Lines.xlsx"
)

print(order_lines.head())
print("Order Lines Row Count: ",(len(order_lines)))


# -----------------------------
# ORDER LINES - BASIC QA
# -----------------------------

duplicate_order_lines = order_lines["Order Line Key"].duplicated().sum()
print("Duplicate Order Line Count: ",(duplicate_order_lines))

missing_order_line_keys = order_lines["Order Line Key"].isna().sum()
print("Missing Order Line Key Count: ",(missing_order_line_keys))

dq_review_count = order_lines["DQ Review"].notna().sum()
print("DQ Review Count: ",(dq_review_count))

missing_order_number = order_lines["Order Number"].isna().sum()
print("Missing Order Number: ", (missing_order_number))

missing_product_codes = order_lines["Product Code"].isna().sum()
print("Missing Product Code Count: ", (missing_product_codes))

missing_account_id = order_lines["Account ID"].isna().sum()
print("Missing Account ID Count: ", (missing_account_id))

missing_line_number = order_lines["Line Number"].isna().sum()
print("Missing Line Number Count: ", (missing_line_number))

dq_review_breakdown = order_lines["DQ Review"].dropna().value_counts()
print("DQ Review Breakdown: ", (dq_review_breakdown))

negative_qty_count = (order_lines["Qty"] < 0).sum()
print("Negative Quantity Count: ", (negative_qty_count))

negative_value_count = (order_lines["Value"] < 0).sum()
print("Negative Value Count: ", (negative_value_count))

negative_cogs_count = (order_lines["Cost of Goods Sold"] < 0).sum()
print("Negative Cost of Goods Sold Count: ", (negative_cogs_count))


# -----------------------------
# ORDER LINES - CALCULATION QA
# -----------------------------

margin_mismatch_count = (
    order_lines["Margin"].round(2)
    != (order_lines["Value"] - order_lines["Cost of Goods Sold"]).round(2)
).sum()

total_mismatch_count = (
    order_lines["Total"].round(2)
    != (
        order_lines["Value"]
        + order_lines["Freight"]
        + order_lines["Tax"]
    ).round(2)
).sum()

product_value_rows = order_lines["Value"] != 0

margin_percent_difference = (
    order_lines.loc[product_value_rows, "Margin %"]
    - (
        order_lines.loc[product_value_rows, "Margin"]
        / order_lines.loc[product_value_rows, "Value"]
    )
).abs()

margin_percent_mismatch_count = (
    margin_percent_difference > 0.0001
).sum()

print("Margin Calculation Mismatch Count:", margin_mismatch_count)
print("Total Calculation Mismatch Count:", total_mismatch_count)
print("Margin % Calculation Mismatch Count:", margin_percent_mismatch_count)


# -----------------------------
# ORDER LINES - SHIPPED QA
# -----------------------------

shipped_product_rows = (
    (order_lines["Line Category"] == "Product")
    & order_lines["Ship Date"].notna()
)

expected_shipped_qty = order_lines["Qty"].where(shipped_product_rows,0)

shipped_qty_mismatch_count = (
    order_lines["Shipped Qty"] != expected_shipped_qty
).sum()

expected_shipped_revenue = order_lines["Value"].where(shipped_product_rows,0)

shipped_revenue_mismatch_count = (
    order_lines["Shipped Revenue"].round(2)
    != expected_shipped_revenue.round(2)
).sum()

print("Shipped Quantity Mismatch Count:", shipped_qty_mismatch_count)
print("Shipped Revenue Mismatch Count:", shipped_revenue_mismatch_count)


# -----------------------------
# ORDER LINES - BACKLOG QA
# -----------------------------

backlog_product_rows = (
    (order_lines["Line Category"] == "Product")
    & order_lines["Ship Date"].isna()
    & (order_lines["Line Status"] != "Shipped")
    & (order_lines["Line Status"] != "Cancelled")
    & (order_lines["Order Status"] != "Cancelled")
)

expected_backlog_qty = order_lines["Qty"].where(backlog_product_rows,0)

backlog_qty_mismatch_count = (
    order_lines["Backlog Qty"] != expected_backlog_qty
).sum()

expected_backlog_value = order_lines["Value"].where(backlog_product_rows,0)

backlog_value_mismatch_count = (
    order_lines["Backlog Value"].round(2)
    != expected_backlog_value.round(2)
).sum()

print("Backlog Quantity Mismatch Count:", backlog_qty_mismatch_count)
print("Backlog Value Mismatch Count:", backlog_value_mismatch_count)


# -----------------------------
# LOAD OTHER CLEANED TABLES
# -----------------------------

accounts = pd.read_excel(
    "../../2. Clean Data/Accounts.xlsx"
)

opportunities = pd.read_excel(
    "../../2. Clean Data/Opportunities.xlsx"
)

orders = pd.read_excel(
    "../../2. Clean Data/Orders.xlsx"
)

returns = pd.read_excel(
    "../../2. Clean Data/Returns.xlsx"
)

warranty = pd.read_excel(
    "../../2. Clean Data/Warranty.xlsx"
)

product_reference = pd.read_excel(
    "../../2. Clean Data/Product Reference.xlsx"
)


# -----------------------------
# TABLE ROW COUNTS
# -----------------------------

print("Accounts Row Count:", len(accounts))
print("Opportunities Row Count:", len(opportunities))
print("Orders Row Count:", len(orders))
print("Returns Row Count:", len(returns))
print("Warranty Row Count:", len(warranty))
print("Product Reference Row Count:", len(product_reference))


# -----------------------------
# ACCOUNTS - BASIC QA
# -----------------------------

duplicate_account_ids = accounts["Account ID"].duplicated().sum()
print("Duplicate Account ID Count:", duplicate_account_ids)

missing_account_ids = accounts["Account ID"].isna().sum()
print("Missing Account ID Count:", missing_account_ids)


# -----------------------------
# OPPORTUNITIES - BASIC QA
# -----------------------------

duplicate_opportunity_ids = opportunities["Opportunity ID"].duplicated().sum()
print("Duplicate Opportunity ID Count:", duplicate_opportunity_ids)

missing_opportunity_ids = opportunities["Opportunity ID"].isna().sum()
print("Missing Opportunity ID Count:", missing_opportunity_ids)

missing_opportunity_account_ids = opportunities["Account ID"].isna().sum()
print(
    "Missing Opportunity Account ID Count:",
    missing_opportunity_account_ids
)


# -----------------------------
# ORDERS - BASIC QA
# -----------------------------

duplicate_order_numbers = orders["Order Number"].duplicated().sum()
print("Duplicate Order Number Count:", duplicate_order_numbers)

missing_order_numbers = orders["Order Number"].isna().sum()
print("Missing Order Number Count:", missing_order_numbers)

missing_order_account_ids = orders["Account ID"].isna().sum()
print("Missing Order Account ID Count:", missing_order_account_ids)


# -----------------------------
# RETURNS - BASIC QA
# -----------------------------

duplicate_rma_numbers = returns["RMA Number"].duplicated().sum()
print("Duplicate RMA Number Count:", duplicate_rma_numbers)

missing_rma_numbers = returns["RMA Number"].isna().sum()
print("Missing RMA Number Count:", missing_rma_numbers)

missing_return_order_numbers = returns["Order Number"].isna().sum()
print("Missing Return Order Number Count:", missing_return_order_numbers)

missing_return_product_codes = returns["Product Code"].isna().sum()
print("Missing Return Product Code Count:", missing_return_product_codes)

missing_return_account_ids = returns["Account ID"].isna().sum()
print("Missing Return Account ID Count:", missing_return_account_ids)


# -----------------------------
# WARRANTY - BASIC QA
# -----------------------------

duplicate_warranty_numbers = warranty["Warranty Number"].duplicated().sum()
print("Duplicate Warranty Number Count:", duplicate_warranty_numbers)

missing_warranty_numbers = warranty["Warranty Number"].isna().sum()
print("Missing Warranty Number Count:", missing_warranty_numbers)

missing_warranty_order_numbers = warranty["Order Number"].isna().sum()
print(
    "Missing Warranty Order Number Count:",
    missing_warranty_order_numbers
)

missing_warranty_product_codes = warranty["Product Code"].isna().sum()
print(
    "Missing Warranty Product Code Count:",
    missing_warranty_product_codes
)

missing_warranty_account_ids = warranty["Account ID"].isna().sum()
print(
    "Missing Warranty Account ID Count:",
    missing_warranty_account_ids
)


# -----------------------------
# PRODUCT REFERENCE - BASIC QA
# -----------------------------

duplicate_reference_product_codes = (
    product_reference["Product Code"].duplicated().sum()
)

print(
    "Duplicate Product Reference Code Count:",
    duplicate_reference_product_codes
)

missing_reference_product_codes = (
    product_reference["Product Code"].isna().sum()
)

print(
    "Missing Product Reference Code Count:",
    missing_reference_product_codes
)


# -----------------------------
# ORDER LINES TO ORDERS
# -----------------------------

invalid_order_line_orders = (
    ~order_lines["Order Number"].isin(
        orders["Order Number"]
    )
).sum()

print(
    "Order Lines with Invalid Order Number:",
    invalid_order_line_orders
)


# -----------------------------
# ORDER LINES TO ACCOUNTS
# -----------------------------

invalid_order_line_accounts = (
    ~order_lines["Account ID"].isin(
        accounts["Account ID"]
    )
).sum()

print(
    "Order Lines with Invalid Account ID:",
    invalid_order_line_accounts
)


# -----------------------------
# ORDER LINES TO PRODUCT REFERENCE
# -----------------------------

invalid_order_line_products = (
    ~order_lines["Product Code"].isin(
        product_reference["Product Code"]
    )
).sum()

print(
    "Order Lines with Invalid Product Code:",
    invalid_order_line_products
)


# -----------------------------
# ORDERS TO ACCOUNTS
# -----------------------------

invalid_order_accounts = (
    ~orders["Account ID"].isin(
        accounts["Account ID"]
    )
).sum()

print(
    "Orders with Invalid Account ID:",
    invalid_order_accounts
)


# -----------------------------
# OPPORTUNITIES TO ACCOUNTS
# -----------------------------

opportunities_with_account_id = (
    opportunities["Account ID"].notna()
)

invalid_opportunity_accounts = (
    ~opportunities.loc[
        opportunities_with_account_id,
        "Account ID"
    ].isin(
        accounts["Account ID"]
    )
).sum()

print(
    "Opportunities with Invalid Account ID:",
    invalid_opportunity_accounts
)

print(
    "Opportunities with Unresolved Account ID:",
    missing_opportunity_account_ids
)


# -----------------------------
# RETURNS - RELATIONSHIP QA
# -----------------------------

invalid_return_orders = (
    ~returns["Order Number"].isin(
        orders["Order Number"]
    )
).sum()

print(
    "Returns with Invalid Order Number:",
    invalid_return_orders
)

returns_with_account_id = (
    returns["Account ID"].notna()
)

invalid_return_accounts = (
    ~returns.loc[
        returns_with_account_id,
        "Account ID"
    ].isin(
        accounts["Account ID"]
    )
).sum()

print(
    "Returns with Invalid Account ID:",
    invalid_return_accounts
)

invalid_return_products = (
    ~returns["Product Code"].isin(
        product_reference["Product Code"]
    )
).sum()

print(
    "Returns with Invalid Product Code:",
    invalid_return_products
)


# -----------------------------
# WARRANTY - RELATIONSHIP QA
# -----------------------------

invalid_warranty_orders = (
    ~warranty["Order Number"].isin(
        orders["Order Number"]
    )
).sum()

print(
    "Warranty Claims with Invalid Order Number:",
    invalid_warranty_orders
)

warranty_with_account_id = (
    warranty["Account ID"].notna()
)

invalid_warranty_accounts = (
    ~warranty.loc[
        warranty_with_account_id,
        "Account ID"
    ].isin(
        accounts["Account ID"]
    )
).sum()

print(
    "Warranty Claims with Invalid Account ID:",
    invalid_warranty_accounts
)

invalid_warranty_products = (
    ~warranty["Product Code"].isin(
        product_reference["Product Code"]
    )
).sum()

print(
    "Warranty Claims with Invalid Product Code:",
    invalid_warranty_products
)


# -----------------------------
# RETURNS TO ORDER LINES
# -----------------------------

return_line_check = returns.merge(
    order_lines[
        [
            "Order Number",
            "Line Number",
            "Product Code"
        ]
    ],
    on=[
        "Order Number",
        "Line Number",
        "Product Code"
    ],
    how="left",
    indicator=True
)

invalid_return_lines = (
    return_line_check["_merge"] == "left_only"
).sum()

print(
    "Returns with Invalid Order Line:",
    invalid_return_lines
)


# -----------------------------
# WARRANTY TO ORDER LINES
# -----------------------------

warranty_line_check = warranty.merge(
    order_lines[
        [
            "Order Number",
            "Line Number",
            "Product Code"
        ]
    ],
    on=[
        "Order Number",
        "Line Number",
        "Product Code"
    ],
    how="left",
    indicator=True
)

invalid_warranty_lines = (
    warranty_line_check["_merge"] == "left_only"
).sum()

print(
    "Warranty Claims with Invalid Order Line:",
    invalid_warranty_lines
)


# -----------------------------
# ORDER HEADER TO ORDER LINE QA
# -----------------------------

order_line_totals = (
    order_lines.groupby("Order Number")[
        [
            "Value",
            "Freight",
            "Tax",
            "Total",
            "Cost of Goods Sold"
        ]
    ].sum()
)

order_check = orders.merge(
    order_line_totals,
    on="Order Number",
    how="left",
    suffixes=("_Order", "_Lines")
)

order_value_mismatch_count = (
    order_check["Value_Order"].round(2)
    != order_check["Value_Lines"].round(2)
).sum()

print(
    "Order Value Mismatch Count:",
    order_value_mismatch_count
)

order_freight_mismatch_count = (
    order_check["Freight_Order"].round(2)
    != order_check["Freight_Lines"].round(2)
).sum()

print(
    "Order Freight Mismatch Count:",
    order_freight_mismatch_count
)

order_tax_mismatch_count = (
    order_check["Tax_Order"].round(2)
    != order_check["Tax_Lines"].round(2)
).sum()

print(
    "Order Tax Mismatch Count:",
    order_tax_mismatch_count
)

order_total_mismatch_count = (
    order_check["Total_Order"].round(2)
    != order_check["Total_Lines"].round(2)
).sum()

print(
    "Order Total Mismatch Count:",
    order_total_mismatch_count
)

order_cogs_mismatch_count = (
    order_check["Cost of Goods Sold_Order"].round(2)
    != order_check["Cost of Goods Sold_Lines"].round(2)
).sum()

print(
    "Order Cost of Goods Sold Mismatch Count:",
    order_cogs_mismatch_count
)


# -----------------------------
# WON OPPORTUNITIES TO ORDERS
# -----------------------------

won_opportunities = opportunities.loc[
    opportunities["Stage"] == "Won"
]

standard_orders = orders.loc[
    orders["Order Type"] == "Order"
]

won_without_order_count = (
    ~won_opportunities["Order Number"].isin(
        standard_orders["Order Number"]
    )
).sum()

print(
    "Won Opportunities Without Standard ERP Order:",
    won_without_order_count
)

standard_order_without_won_count = (
    ~standard_orders["Order Number"].isin(
        won_opportunities["Order Number"]
    )
).sum()

print(
    "Standard ERP Orders Without Won Opportunity:",
    standard_order_without_won_count
)


# -----------------------------
# WARRANTY REPLACEMENT ORDERS
# -----------------------------

warranty_with_replacement_order = (
    warranty["Replacement Order Number"].notna()
)

warranty_order_numbers = orders.loc[
    orders["Order Type"] == "Warranty",
    "Order Number"
]

invalid_warranty_replacement_orders = (
    ~warranty.loc[
        warranty_with_replacement_order,
        "Replacement Order Number"
    ].isin(
        warranty_order_numbers
    )
).sum()

print(
    "Invalid Warranty Replacement Order Count:",
    invalid_warranty_replacement_orders
)


# -----------------------------
# QA COMPLETE
# -----------------------------

print("Python QA Review Complete")