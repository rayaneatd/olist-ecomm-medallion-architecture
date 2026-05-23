-- =============================================================================
-- OLIST E-COMMERCE — SQL DATABASE SCHEMA (Post-2018 Migration)
-- Microsoft Fabric SQL Database
-- =============================================================================
-- CONTEXT:
--   This schema represents the operational database adopted by Olist in early
--   2019, replacing manual CSV exports. Several design decisions reflect real
--   migration patterns:
--
--   SCHEMA EVOLUTION vs. CSV (justified differences):
--   1. Categories are stored in English directly — the translation table was
--      merged into products during the SQL migration to eliminate the join
--      needed in the legacy CSV pipeline.
--   2. `customer_state` → renamed `shipping_state`, `shipping_city` to clarify
--      that the address is the delivery address, not the customer's registered
--      address (a distinction that caused reporting confusion in the CSV era).
--   3. `product_name_lenght` / `product_description_lenght` (typos in legacy)
--      corrected to `product_name_length` / `product_description_length`.
--   4. `review_score` (1–5) replaced by `satisfaction_score` (0–100) to align
--      with a CSAT methodology adopted company-wide in 2019.
--   5. A new `order_channel` column tracks whether the order came from the
--      web, mobile app, or a third-party marketplace integration.
--   6. `payment_type` is now an FK to a `ref.dim_payment_method` lookup table
--      instead of a raw string — prevents dirty data like 'not_defined'.
--   7. Geolocation is decoupled into its own normalized table, referenced
--      from both customers and sellers via zip_code FK.
--   8. A soft-delete pattern (`deleted_at`) is added on mutable entities
--      (customers, sellers) — unavailable in the flat CSV model.
--
-- DOMAIN SCHEMAS:
--   ref         → lookup / reference tables (statuses, payment methods, channels)
--   geo         → geolocation data
--   marketplace → customers, sellers
--   catalog     → products and product categories
--   sales       → orders, order items, payments, reviews
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- SCHEMAS
-- ─────────────────────────────────────────────────────────────────────────────

CREATE SCHEMA ref;
GO
CREATE SCHEMA geo;
GO
CREATE SCHEMA marketplace;
GO
CREATE SCHEMA catalog;
GO
CREATE SCHEMA sales;
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- ref — LOOKUP / REFERENCE TABLES
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE ref.order_statuses (
    status_id       TINYINT         NOT NULL,
    status_code     VARCHAR(20)     NOT NULL,   -- 'delivered', 'shipped', etc.
    status_label    NVARCHAR(50)    NOT NULL,
    is_terminal     BIT             NOT NULL DEFAULT 0,  -- TRUE = final state
    CONSTRAINT PK_order_statuses PRIMARY KEY (status_id),
    CONSTRAINT UQ_order_statuses_code UNIQUE (status_code)
);

CREATE TABLE ref.payment_methods (
    payment_method_id   TINYINT         NOT NULL,
    method_code         VARCHAR(30)     NOT NULL,   -- 'credit_card', 'boleto', etc.
    method_label        NVARCHAR(60)    NOT NULL,
    is_active           BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_payment_methods PRIMARY KEY (payment_method_id),
    CONSTRAINT UQ_payment_methods_code UNIQUE (method_code)
);

CREATE TABLE ref.order_channels (
    channel_id      TINYINT         NOT NULL,
    channel_code    VARCHAR(20)     NOT NULL,   -- 'web', 'app', 'marketplace'
    channel_label   NVARCHAR(50)    NOT NULL,
    CONSTRAINT PK_order_channels PRIMARY KEY (channel_id),
    CONSTRAINT UQ_order_channels_code UNIQUE (channel_code)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- catalog — PRODUCT CATEGORIES
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE catalog.product_categories (
    category_id        SMALLINT        NOT NULL IDENTITY(1,1),
    category_code      VARCHAR(60)     NOT NULL,   -- slug in English
    category_label     NVARCHAR(80)    NOT NULL,   -- display name
    parent_category_id SMALLINT        NULL,       -- optional hierarchy (new in SQL era)
    CONSTRAINT PK_product_categories PRIMARY KEY (category_id),
    CONSTRAINT UQ_product_categories_code UNIQUE (category_code),
    CONSTRAINT FK_product_category_parent FOREIGN KEY (parent_category_id)
        REFERENCES catalog.product_categories (category_id)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- geo — GEOLOCATION
-- ─────────────────────────────────────────────────────────────────────────────

-- Normalized: one row per zip prefix + city/state combination
-- (replaces the denormalized olist_geolocation_dataset.csv with many dupes)
CREATE TABLE geo.geolocation (
    geo_id              INT             NOT NULL IDENTITY(1,1),
    zip_code_prefix     CHAR(5)         NOT NULL,
    geo_lat             DECIMAL(10,7)   NOT NULL,
    geo_lng             DECIMAL(10,7)   NOT NULL,
    city                NVARCHAR(80)    NOT NULL,
    state_code          CHAR(2)         NOT NULL,   -- BR state abbreviation
    CONSTRAINT PK_geolocation PRIMARY KEY (geo_id),
    CONSTRAINT UQ_geolocation_zip_coords UNIQUE (zip_code_prefix, geo_lat, geo_lng)
);

CREATE INDEX IX_geolocation_zip ON geo.geolocation (zip_code_prefix);

-- ─────────────────────────────────────────────────────────────────────────────
-- marketplace — CUSTOMERS & SELLERS
-- ─────────────────────────────────────────────────────────────────────────────

-- EVOLUTION NOTE: `customer_city` / `customer_state` → `shipping_city` /
-- `shipping_state` to reflect that the stored address is the delivery address.
-- `customer_unique_id` becomes the business key kept as `customer_key` to
-- distinguish from the per-order `customer_id` concept of the CSV era.

CREATE TABLE marketplace.customers (
    customer_id         CHAR(32)        NOT NULL,   -- UUID-like hash, PK
    customer_key        CHAR(32)        NOT NULL,   -- unique customer business key
    zip_code_prefix     CHAR(5)         NULL,
    shipping_city       NVARCHAR(80)    NULL,
    shipping_state      CHAR(2)         NULL,
    registered_at       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    deleted_at          DATETIME2(0)    NULL,       -- soft delete (new in SQL era)
    CONSTRAINT PK_customers PRIMARY KEY (customer_id),
    CONSTRAINT UQ_customers_key UNIQUE (customer_key)
);

CREATE INDEX IX_customers_zip   ON marketplace.customers (zip_code_prefix);
CREATE INDEX IX_customers_state ON marketplace.customers (shipping_state);

CREATE TABLE marketplace.sellers (
    seller_id           CHAR(32)        NOT NULL,
    zip_code_prefix     CHAR(5)         NULL,
    seller_city         NVARCHAR(80)    NULL,
    seller_state        CHAR(2)         NULL,
    onboarded_at        DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    deleted_at          DATETIME2(0)    NULL,
    CONSTRAINT PK_sellers PRIMARY KEY (seller_id)
);

CREATE INDEX IX_sellers_state ON marketplace.sellers (seller_state);

-- ─────────────────────────────────────────────────────────────────────────────
-- catalog — PRODUCTS
-- ─────────────────────────────────────────────────────────────────────────────

-- EVOLUTION NOTES:
--   - category stored as FK to catalog.dim_product_category (no more raw Portuguese string)
--   - typos corrected: length not lenght
--   - `product_photos_qty` → `photo_count`

CREATE TABLE catalog.products (
    product_id              CHAR(32)        NOT NULL,
    category_id             SMALLINT        NULL,
    product_name_length     SMALLINT        NULL,
    product_description_length INT          NULL,
    photo_count             TINYINT         NULL,
    weight_g                INT             NULL,
    length_cm               SMALLINT        NULL,
    height_cm               SMALLINT        NULL,
    width_cm                SMALLINT        NULL,
    created_at              DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_products PRIMARY KEY (product_id),
    CONSTRAINT FK_products_category FOREIGN KEY (category_id)
        REFERENCES catalog.product_categories (category_id)
);

CREATE INDEX IX_products_category ON catalog.products (category_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- sales — ORDERS, ITEMS, PAYMENTS, REVIEWS
-- ─────────────────────────────────────────────────────────────────────────────

-- EVOLUTION NOTE:
--   - status is now an FK to ref.dim_order_status (no more raw strings)
--   - `order_channel` is new — tracks acquisition channel
--   - timestamps stored as DATETIME2(0) (UTC) — old CSV had no explicit TZ

CREATE TABLE sales.orders (
    order_id                CHAR(32)        NOT NULL,
    customer_id             CHAR(32)        NOT NULL,
    status_id               TINYINT         NOT NULL,
    channel_id              TINYINT         NOT NULL,
    purchased_at            DATETIME2(0)    NOT NULL,
    approved_at             DATETIME2(0)    NULL,
    carrier_pickup_at       DATETIME2(0)    NULL,
    delivered_at            DATETIME2(0)    NULL,
    estimated_delivery_date DATE            NOT NULL,
    CONSTRAINT PK_orders PRIMARY KEY (order_id),
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id)
        REFERENCES marketplace.customers (customer_id),
    CONSTRAINT FK_orders_status FOREIGN KEY (status_id)
        REFERENCES ref.order_statuses (status_id),
    CONSTRAINT FK_orders_channel FOREIGN KEY (channel_id)
        REFERENCES ref.order_channels (channel_id)
);

CREATE INDEX IX_orders_customer     ON sales.orders (customer_id);
CREATE INDEX IX_orders_purchased_at ON sales.orders (purchased_at);
CREATE INDEX IX_orders_status       ON sales.orders (status_id);

CREATE TABLE sales.order_items (
    order_id                CHAR(32)        NOT NULL,
    order_item_seq          TINYINT         NOT NULL,   -- was `order_item_id`
    product_id              CHAR(32)        NOT NULL,
    seller_id               CHAR(32)        NOT NULL,
    shipping_limit_at       DATETIME2(0)    NOT NULL,
    unit_price              DECIMAL(10,2)   NOT NULL,
    freight_value           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_order_items PRIMARY KEY (order_id, order_item_seq),
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id)
        REFERENCES catalog.products (product_id),
    CONSTRAINT FK_order_items_seller FOREIGN KEY (seller_id)
        REFERENCES marketplace.sellers (seller_id),
    CONSTRAINT CHK_order_items_price   CHECK (unit_price    >= 0),
    CONSTRAINT CHK_order_items_freight CHECK (freight_value >= 0)
);

CREATE INDEX IX_order_items_product ON sales.order_items (product_id);
CREATE INDEX IX_order_items_seller  ON sales.order_items (seller_id);

-- EVOLUTION NOTE:
--   - `payment_type` (raw string) → FK to ref.dim_payment_method
--   - `payment_sequential` → `payment_seq`

CREATE TABLE sales.order_payments (
    order_id                CHAR(32)        NOT NULL,
    payment_seq             TINYINT         NOT NULL,
    payment_method_id       TINYINT         NOT NULL,
    installments            TINYINT         NOT NULL DEFAULT 1,
    payment_value           DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_order_payments PRIMARY KEY (order_id, payment_seq),
    CONSTRAINT FK_order_payments_order FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id),
    CONSTRAINT FK_order_payments_method FOREIGN KEY (payment_method_id)
        REFERENCES ref.payment_methods (payment_method_id),
    CONSTRAINT CHK_order_payments_value        CHECK (payment_value  >= 0),
    CONSTRAINT CHK_order_payments_installments CHECK (installments   >= 1)
);

-- EVOLUTION NOTE:
--   - `review_score` (1–5 integer) → `satisfaction_score` (0–100 integer)
--     Conversion used at migration: satisfaction_score = (review_score - 1) * 25
--   - `review_comment_title` dropped (was >95% NULL in CSV data, not useful)
--   - `review_answer_timestamp` → `responded_at`

CREATE TABLE sales.order_reviews (
    review_id               CHAR(32)        NOT NULL,
    order_id                CHAR(32)        NOT NULL,
    satisfaction_score      TINYINT         NOT NULL,   -- 0, 25, 50, 75, 100
    comment_message         NVARCHAR(1000)  NULL,
    created_at              DATETIME2(0)    NOT NULL,
    responded_at            DATETIME2(0)    NULL,
    CONSTRAINT PK_order_reviews PRIMARY KEY (review_id),
    CONSTRAINT FK_order_reviews_order FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id),
    CONSTRAINT CHK_order_reviews_score CHECK (satisfaction_score BETWEEN 0 AND 100)
);

CREATE INDEX IX_order_reviews_order ON sales.order_reviews (order_id);
