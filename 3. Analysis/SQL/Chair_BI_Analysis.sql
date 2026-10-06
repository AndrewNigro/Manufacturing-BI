-- -----------------------------
-- TABLE ROW COUNTS
-- -----------------------------

SELECT COUNT(*) AS AccountRowCount
FROM accounts;

SELECT COUNT(*) AS OpportunityRowCount
FROM opportunities;

SELECT COUNT(*) AS OrderRowCount
FROM orders;

SELECT COUNT(*) AS OrderLineRowCount
FROM order_lines;

SELECT COUNT(*) AS ReturnRowCount
FROM returns;

SELECT COUNT(*) AS WarrantyRowCount
FROM warranty;

SELECT COUNT(*) AS ProductReferenceRowCount
FROM product_reference;


-- -----------------------------
-- REVIEW ORDER LINES
-- -----------------------------

SELECT *
FROM order_lines
LIMIT 10;

SELECT COUNT(*) AS NegativeQuantityCount
FROM order_lines
WHERE "Qty" < 0;

SELECT COUNT(*) AS NegativeValueCount
FROM order_lines
WHERE "Value" < 0;

SELECT COUNT(*) AS NegativeCOGSCount
FROM order_lines
WHERE "Cost of Goods Sold" < 0;

SELECT COUNT(*) AS MissingOrderLineKeyCount
FROM order_lines
WHERE "Order Line Key" IS NULL;

SELECT COUNT(*) AS MissingOrderNumberCount
FROM order_lines
WHERE "Order Number" IS NULL;

SELECT COUNT(*) AS MissingProductCodeCount
FROM order_lines
WHERE "Product Code" IS NULL;

SELECT COUNT(*) AS MissingAccountIDCount
FROM order_lines
WHERE "Account ID" IS NULL;

SELECT COUNT(*) AS MissingLineNumberCount
FROM order_lines
WHERE "Line Number" IS NULL;


-- -----------------------------
-- ORDER LINES - DUPLICATE AND DQ CHECKS
-- -----------------------------

SELECT
    "Order Line Key",
    COUNT(*) AS DuplicateCount
FROM order_lines
GROUP BY "Order Line Key"
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS DQReviewCount
FROM order_lines
WHERE "DQ Review" IS NOT NULL;

SELECT
    "DQ Review",
    COUNT(*) AS IssueCount
FROM order_lines
WHERE "DQ Review" IS NOT NULL
GROUP BY "DQ Review"
ORDER BY IssueCount DESC;


-- -----------------------------
-- ORDER LINES - CALCULATION QA
-- -----------------------------

SELECT COUNT(*) AS MarginCalculationMismatchCount
FROM order_lines
WHERE ROUND("Margin", 2)
    != ROUND("Value" - "Cost of Goods Sold", 2);

SELECT COUNT(*) AS TotalCalculationMismatchCount
FROM order_lines
WHERE ROUND("Total", 2)
    != ROUND("Value" + "Freight" + "Tax", 2);

SELECT COUNT(*) AS MarginPercentMismatchCount
FROM order_lines
WHERE "Value" != 0
    AND ABS(
        "Margin %" - ("Margin" / "Value")
    ) > 0.0001;


-- -----------------------------
-- ORDER LINES - SHIPPED QA
-- -----------------------------

SELECT COUNT(*) AS ShippedQuantityMismatchCount
FROM order_lines
WHERE "Shipped Qty" !=
    CASE
        WHEN "Line Category" = 'Product'
            AND "Ship Date" IS NOT NULL
        THEN "Qty"
        ELSE 0
    END;

SELECT COUNT(*) AS ShippedRevenueMismatchCount
FROM order_lines
WHERE ROUND("Shipped Revenue", 2) !=
    ROUND(
        CASE
            WHEN "Line Category" = 'Product'
                AND "Ship Date" IS NOT NULL
            THEN "Value"
            ELSE 0
        END,
        2
    );


-- -----------------------------
-- ORDER LINES - BACKLOG QA
-- -----------------------------

SELECT COUNT(*) AS BacklogQuantityMismatchCount
FROM order_lines
WHERE "Backlog Qty" !=
    CASE
        WHEN "Line Category" = 'Product'
            AND "Ship Date" IS NULL
            AND "Line Status" != 'Shipped'
            AND "Line Status" != 'Cancelled'
            AND "Order Status" != 'Cancelled'
        THEN "Qty"
        ELSE 0
    END;

SELECT COUNT(*) AS BacklogValueMismatchCount
FROM order_lines
WHERE ROUND("Backlog Value", 2) !=
    ROUND(
        CASE
            WHEN "Line Category" = 'Product'
                AND "Ship Date" IS NULL
                AND "Line Status" != 'Shipped'
                AND "Line Status" != 'Cancelled'
                AND "Order Status" != 'Cancelled'
            THEN "Value"
            ELSE 0
        END,
        2
    );


-- -----------------------------
-- OTHER TABLES - KEY QA
-- -----------------------------

SELECT
    "Account ID",
    COUNT(*) AS DuplicateCount
FROM accounts
GROUP BY "Account ID"
HAVING COUNT(*) > 1;

SELECT
    "Opportunity ID",
    COUNT(*) AS DuplicateCount
FROM opportunities
GROUP BY "Opportunity ID"
HAVING COUNT(*) > 1;

SELECT
    "Order Number",
    COUNT(*) AS DuplicateCount
FROM orders
GROUP BY "Order Number"
HAVING COUNT(*) > 1;

SELECT
    "RMA Number",
    COUNT(*) AS DuplicateCount
FROM returns
GROUP BY "RMA Number"
HAVING COUNT(*) > 1;

SELECT
    "Warranty Number",
    COUNT(*) AS DuplicateCount
FROM warranty
GROUP BY "Warranty Number"
HAVING COUNT(*) > 1;

SELECT
    "Product Code",
    COUNT(*) AS DuplicateCount
FROM product_reference
GROUP BY "Product Code"
HAVING COUNT(*) > 1;


-- -----------------------------
-- CROSS-TABLE RELATIONSHIP QA
-- -----------------------------

SELECT COUNT(*) AS OrderLinesWithInvalidOrderNumber
FROM order_lines
LEFT JOIN orders
    ON order_lines."Order Number" = orders."Order Number"
WHERE orders."Order Number" IS NULL;

SELECT COUNT(*) AS OrdersWithInvalidAccountID
FROM orders
LEFT JOIN accounts
    ON orders."Account ID" = accounts."Account ID"
WHERE accounts."Account ID" IS NULL;

SELECT COUNT(*) AS OrderLinesWithInvalidAccountID
FROM order_lines
LEFT JOIN accounts
    ON order_lines."Account ID" = accounts."Account ID"
WHERE accounts."Account ID" IS NULL;

SELECT COUNT(*) AS OrderLinesWithInvalidProductCode
FROM order_lines
LEFT JOIN product_reference
    ON order_lines."Product Code" = product_reference."Product Code"
WHERE product_reference."Product Code" IS NULL;

SELECT COUNT(*) AS OpportunitiesWithUnresolvedAccountID
FROM opportunities
WHERE "Account ID" IS NULL;

SELECT COUNT(*) AS OpportunitiesWithInvalidAccountID
FROM opportunities
LEFT JOIN accounts
    ON opportunities."Account ID" = accounts."Account ID"
WHERE opportunities."Account ID" IS NOT NULL
    AND accounts."Account ID" IS NULL;

SELECT COUNT(*) AS ReturnsWithInvalidOrderLineKey
FROM returns
LEFT JOIN order_lines
    ON returns."Order Line Key" = order_lines."Order Line Key"
WHERE order_lines."Order Line Key" IS NULL;

SELECT COUNT(*) AS WarrantyWithInvalidOrderLineKey
FROM warranty
LEFT JOIN order_lines
    ON warranty."Order Line Key" = order_lines."Order Line Key"
WHERE order_lines."Order Line Key" IS NULL;


-- -----------------------------
-- ORDER HEADER TO ORDER LINE RECONCILIATION
-- -----------------------------

WITH order_line_totals AS (
    SELECT
        "Order Number",
        SUM("Value") AS LineValue,
        SUM("Freight") AS LineFreight,
        SUM("Tax") AS LineTax,
        SUM("Total") AS LineTotal,
        SUM("Cost of Goods Sold") AS LineCOGS
    FROM order_lines
    GROUP BY "Order Number"
)

SELECT
    SUM(
        CASE
            WHEN ROUND(orders."Value", 2)
                != ROUND(order_line_totals.LineValue, 2)
            THEN 1
            ELSE 0
        END
    ) AS ValueMismatchCount,

    SUM(
        CASE
            WHEN ROUND(orders."Freight", 2)
                != ROUND(order_line_totals.LineFreight, 2)
            THEN 1
            ELSE 0
        END
    ) AS FreightMismatchCount,

    SUM(
        CASE
            WHEN ROUND(orders."Tax", 2)
                != ROUND(order_line_totals.LineTax, 2)
            THEN 1
            ELSE 0
        END
    ) AS TaxMismatchCount,

    SUM(
        CASE
            WHEN ROUND(orders."Total", 2)
                != ROUND(order_line_totals.LineTotal, 2)
            THEN 1
            ELSE 0
        END
    ) AS TotalMismatchCount,

    SUM(
        CASE
            WHEN ROUND(orders."Cost of Goods Sold", 2)
                != ROUND(order_line_totals.LineCOGS, 2)
            THEN 1
            ELSE 0
        END
    ) AS COGSMismatchCount

FROM orders
LEFT JOIN order_line_totals
    ON orders."Order Number" = order_line_totals."Order Number";


-- ============================================================
-- BUSINESS ANALYSIS
-- ============================================================


-- -----------------------------
-- WON SALES BY YEAR
-- -----------------------------

SELECT
    strftime('%Y', "Close Date") AS CloseYear,
    COUNT(*) AS WonOpportunityCount,
    ROUND(SUM("Value"), 2) AS WonValue
FROM opportunities
WHERE "Stage" = 'Won'
GROUP BY CloseYear
ORDER BY CloseYear;


-- -----------------------------
-- OPEN PIPELINE BY SALES REP AND STAGE
-- -----------------------------

SELECT
    "Sales Rep",
    "Stage",
    COUNT(*) AS OpportunityCount,
    ROUND(SUM("Value"), 2) AS PipelineValue
FROM opportunities
WHERE "Is Open" = 1
GROUP BY
    "Sales Rep",
    "Stage"
ORDER BY
    "Sales Rep",
    PipelineValue DESC;


-- -----------------------------
-- STALE OPPORTUNITIES
-- -----------------------------

SELECT
    "Opportunity ID",
    "Order Number",
    "Account Name",
    "Sales Rep",
    "Stage",
    "Value",
    "Close Date",
    "Last Activity Date"
FROM opportunities
WHERE "Is Open" = 1
    AND "Stale" = 1
ORDER BY "Close Date";


-- -----------------------------
-- SHIPPED REVENUE BY YEAR
-- -----------------------------

SELECT
    strftime('%Y', "Ship Date") AS ShipYear,
    ROUND(SUM("Shipped Revenue"), 2) AS ShippedRevenue
FROM order_lines
WHERE "Line Category" = 'Product'
    AND "Ship Date" IS NOT NULL
GROUP BY ShipYear
ORDER BY ShipYear;


-- -----------------------------
-- BACKLOG BY SALES REP
-- -----------------------------

SELECT
    "Sales Rep",
    SUM("Backlog Qty") AS BacklogQty,
    ROUND(SUM("Backlog Value"), 2) AS BacklogValue
FROM order_lines
WHERE "Backlog Value" > 0
GROUP BY "Sales Rep"
ORDER BY BacklogValue DESC;


-- -----------------------------
-- PRODUCT SALES
-- -----------------------------

SELECT
    product_reference."Product Family",
    product_reference."Model",
    order_lines."Product Code",
    SUM(order_lines."Shipped Qty") AS ShippedQty,
    ROUND(
        SUM(order_lines."Shipped Revenue"),
        2
    ) AS ShippedRevenue
FROM order_lines
LEFT JOIN product_reference
    ON order_lines."Product Code"
        = product_reference."Product Code"
WHERE order_lines."Line Category" = 'Product'
    AND order_lines."Ship Date" IS NOT NULL
GROUP BY
    product_reference."Product Family",
    product_reference."Model",
    order_lines."Product Code"
ORDER BY ShippedRevenue DESC;


-- -----------------------------
-- MARGIN BY PRODUCT FAMILY
-- -----------------------------

SELECT
    product_reference."Product Family",
    ROUND(
        SUM(order_lines."Shipped Revenue"),
        2
    ) AS ShippedRevenue,
    ROUND(
        SUM(order_lines."Margin"),
        2
    ) AS Margin,
    ROUND(
        100.0 * SUM(order_lines."Margin")
        / NULLIF(
            SUM(order_lines."Shipped Revenue"),
            0
        ),
        2
    ) AS MarginPercent
FROM order_lines
LEFT JOIN product_reference
    ON order_lines."Product Code"
        = product_reference."Product Code"
WHERE order_lines."Line Category" = 'Product'
    AND order_lines."Ship Date" IS NOT NULL
GROUP BY product_reference."Product Family"
ORDER BY ShippedRevenue DESC;


-- -----------------------------
-- SALES REP - WON PERFORMANCE
-- -----------------------------

SELECT
    "Sales Rep",
    COUNT(*) AS WonOpportunityCount,
    ROUND(SUM("Value"), 2) AS WonValue
FROM opportunities
WHERE "Stage" = 'Won'
GROUP BY "Sales Rep"
ORDER BY WonValue DESC;


-- -----------------------------
-- SALES REP - SHIPPED PERFORMANCE
-- -----------------------------

SELECT
    "Sales Rep",
    ROUND(
        SUM("Shipped Revenue"),
        2
    ) AS ShippedRevenue,
    ROUND(
        SUM("Margin"),
        2
    ) AS Margin,
    ROUND(
        100.0 * SUM("Margin")
        / NULLIF(
            SUM("Shipped Revenue"),
            0
        ),
        2
    ) AS MarginPercent
FROM order_lines
WHERE "Line Category" = 'Product'
    AND "Ship Date" IS NOT NULL
GROUP BY "Sales Rep"
ORDER BY ShippedRevenue DESC;


-- -----------------------------
-- RETURN REASONS
-- -----------------------------

SELECT
    "Return Reason",
    COUNT(*) AS ReturnCount,
    SUM("Qty") AS ReturnQty,
    ROUND(SUM("Refund"), 2) AS RefundAmount
FROM returns
GROUP BY "Return Reason"
ORDER BY ReturnCount DESC;


-- -----------------------------
-- WARRANTY CLAIM REASONS
-- -----------------------------

SELECT
    "Claim Reason",
    COUNT(*) AS ClaimCount,
    SUM("Qty") AS ClaimQty
FROM warranty
GROUP BY "Claim Reason"
ORDER BY ClaimCount DESC;


-- -----------------------------
-- ON-TIME PERFORMANCE
-- -----------------------------

SELECT
    SUM(
        CASE
            WHEN "On Time Status" IN (
                'On Time',
                'On Time - Customer Payment Hold'
            )
            THEN 1
            ELSE 0
        END
    ) AS OnTimeOrders,

    SUM(
        CASE
            WHEN "On Time Status" = 'Late'
            THEN 1
            ELSE 0
        END
    ) AS LateOrders,

    ROUND(
        100.0
        * SUM(
            CASE
                WHEN "On Time Status" IN (
                    'On Time',
                    'On Time - Customer Payment Hold'
                )
                THEN 1
                ELSE 0
            END
        )
        / NULLIF(
            SUM(
                CASE
                    WHEN "On Time Status" IN (
                        'On Time',
                        'On Time - Customer Payment Hold',
                        'Late'
                    )
                    THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS OnTimePercent

FROM orders;


-- -----------------------------
-- LOST OPPORTUNITY REASONS
-- -----------------------------

SELECT
    "Lost Reason",
    COUNT(*) AS LostOpportunityCount,
    ROUND(SUM("Value"), 2) AS LostValue
FROM opportunities
WHERE "Stage" = 'Lost'
GROUP BY "Lost Reason"
ORDER BY LostValue DESC;


-- -----------------------------
-- ORDER CANCELLATION REASONS
-- -----------------------------

SELECT
    "Cancel Reason",
    COUNT(*) AS CancelledOrderCount,
    ROUND(SUM("Value"), 2) AS CancelledValue
FROM orders
WHERE "Order Status" = 'Cancelled'
GROUP BY "Cancel Reason"
ORDER BY CancelledValue DESC;


-- -----------------------------
-- TOP ACCOUNTS BY SHIPPED REVENUE
-- -----------------------------

WITH account_sales AS (
    SELECT
        accounts."Account ID",
        accounts."Account Name",
        ROUND(
            SUM(order_lines."Shipped Revenue"),
            2
        ) AS ShippedRevenue
    FROM accounts
    LEFT JOIN order_lines
        ON accounts."Account ID"
            = order_lines."Account ID"
    WHERE order_lines."Line Category" = 'Product'
        AND order_lines."Ship Date" IS NOT NULL
    GROUP BY
        accounts."Account ID",
        accounts."Account Name"
)

SELECT
    "Account ID",
    "Account Name",
    ShippedRevenue,
    RANK() OVER (
        ORDER BY ShippedRevenue DESC
    ) AS RevenueRank
FROM account_sales
ORDER BY RevenueRank
LIMIT 10;


-- -----------------------------
-- REPEAT BUSINESS
-- -----------------------------

SELECT
    accounts."Account ID",
    accounts."Account Name",
    COUNT(
        DISTINCT orders."Order Number"
    ) AS StandardOrderCount
FROM accounts
LEFT JOIN orders
    ON accounts."Account ID"
        = orders."Account ID"
    AND orders."Order Type" = 'Order'
    AND orders."Order Status" != 'Cancelled'
GROUP BY
    accounts."Account ID",
    accounts."Account Name"
HAVING COUNT(
    DISTINCT orders."Order Number"
) > 1
ORDER BY StandardOrderCount DESC;


-- -----------------------------
-- BOOKINGS VS BACKLOG VS SHIPMENTS
-- -----------------------------

WITH bookings AS (
    SELECT
        SUM("Value") AS BookedValue
    FROM opportunities
    WHERE "Stage" = 'Won'
),

backlog AS (
    SELECT
        SUM("Backlog Value") AS BacklogValue
    FROM order_lines
),

shipments AS (
    SELECT
        SUM("Shipped Revenue") AS ShippedValue
    FROM order_lines
)

SELECT
    ROUND(
        bookings.BookedValue,
        2
    ) AS BookedValue,

    ROUND(
        backlog.BacklogValue,
        2
    ) AS BacklogValue,

    ROUND(
        shipments.ShippedValue,
        2
    ) AS ShippedValue

FROM bookings
CROSS JOIN backlog
CROSS JOIN shipments;


-- -----------------------------
-- SQL ANALYSIS COMPLETE
-- -----------------------------