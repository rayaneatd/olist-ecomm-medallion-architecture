CREATE TABLE [marketplace].[customers] (
    [customer_id]     CHAR (32)     NOT NULL,
    [customer_key]    CHAR (32)     NOT NULL,
    [zip_code_prefix] CHAR (5)      NULL,
    [shipping_city]   NVARCHAR (80) NULL,
    [shipping_state]  CHAR (2)      NULL,
    [registered_at]   DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    [deleted_at]      DATETIME2 (0) NULL,
    CONSTRAINT [PK_customers] PRIMARY KEY CLUSTERED ([customer_id] ASC),
    CONSTRAINT [UQ_customers_key] UNIQUE NONCLUSTERED ([customer_key] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_customers_state]
    ON [marketplace].[customers]([shipping_state] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_customers_zip]
    ON [marketplace].[customers]([zip_code_prefix] ASC);


GO

