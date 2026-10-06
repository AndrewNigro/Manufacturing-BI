import pandas as pd
import sqlite3


accounts = pd.read_excel(
    "../../2. Clean Data/Accounts.xlsx"
)

opportunities = pd.read_excel(
    "../../2. Clean Data/Opportunities.xlsx"
)

orders = pd.read_excel(
    "../../2. Clean Data/Orders.xlsx"
)

order_lines = pd.read_excel(
    "../../2. Clean Data/Order Lines.xlsx"
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


connection = sqlite3.connect(
    "Chair_Manufacturing.db"
)


accounts.to_sql(
    "accounts",
    connection,
    if_exists="replace",
    index=False
)

opportunities.to_sql(
    "opportunities",
    connection,
    if_exists="replace",
    index=False
)

orders.to_sql(
    "orders",
    connection,
    if_exists="replace",
    index=False
)

order_lines.to_sql(
    "order_lines",
    connection,
    if_exists="replace",
    index=False
)

returns.to_sql(
    "returns",
    connection,
    if_exists="replace",
    index=False
)

warranty.to_sql(
    "warranty",
    connection,
    if_exists="replace",
    index=False
)

product_reference.to_sql(
    "product_reference",
    connection,
    if_exists="replace",
    index=False
)


connection.close()

print("SQLite database created successfully.")