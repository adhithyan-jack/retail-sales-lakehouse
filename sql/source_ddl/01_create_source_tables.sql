-- 1. Customers: one row per customer_id (Olist creates a new customer_id per order)
CREATE TABLE dbo.customers (
    customer_id               CHAR(32)      NOT NULL PRIMARY KEY,
    customer_unique_id        CHAR(32)      NOT NULL,   -- the real person; business key for dim_customer later
    customer_zip_code_prefix  CHAR(5)       NULL,       -- text, keeps leading zeros
    customer_city             NVARCHAR(100) NULL,       -- Unicode for accents (são paulo)
    customer_state            CHAR(2)       NULL,
    updated_at                DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()  -- watermark column
);

-- 2. Orders: one row per order
CREATE TABLE dbo.orders (
    order_id                       CHAR(32)    NOT NULL PRIMARY KEY,
    customer_id                    CHAR(32)    NOT NULL,
    order_status                   VARCHAR(20) NOT NULL,
    order_purchase_timestamp       DATETIME2   NOT NULL,
    order_approved_at              DATETIME2   NULL,   -- NULL = not approved (e.g. canceled)
    order_delivered_carrier_date   DATETIME2   NULL,   -- NULL = not shipped yet
    order_delivered_customer_date  DATETIME2   NULL,   -- NULL = not delivered yet
    order_estimated_delivery_date  DATETIME2   NULL,
    updated_at                     DATETIME2   NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 3. Order items: one row per product line within an order
CREATE TABLE dbo.order_items (
    order_id             CHAR(32)       NOT NULL,
    order_item_id        INT            NOT NULL,   -- 1, 2, 3... within each order
    product_id           CHAR(32)       NOT NULL,
    seller_id            CHAR(32)       NOT NULL,
    shipping_limit_date  DATETIME2      NOT NULL,
    price                DECIMAL(10,2)  NOT NULL,   -- exact decimal, never FLOAT for money
    freight_value        DECIMAL(10,2)  NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id)   -- composite key
);

-- 4. Order payments: one row per payment within an order
CREATE TABLE dbo.order_payments (
    order_id              CHAR(32)       NOT NULL,
    payment_sequential    INT            NOT NULL,   -- 1, 2... if an order is paid in several parts
    payment_type          VARCHAR(20)    NOT NULL,   -- credit_card, boleto, voucher, debit_card
    payment_installments  INT            NOT NULL,
    payment_value         DECIMAL(10,2)  NOT NULL,
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential)
);