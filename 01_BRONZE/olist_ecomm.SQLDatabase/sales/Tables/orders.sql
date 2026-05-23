CREATE TABLE [sales].[orders] (
    [order_id]                CHAR (32)     NOT NULL,
    [customer_id]             CHAR (32)     NOT NULL,
    [status_id]               TINYINT       NOT NULL,
    [channel_id]              TINYINT       NOT NULL,
    [purchased_at]            DATETIME2 (0) NOT NULL,
    [approved_at]             DATETIME2 (0) NULL,
    [carrier_pickup_at]       DATETIME2 (0) NULL,
    [delivered_at]            DATETIME2 (0) NULL,
    [estimated_delivery_date] DATE          NOT NULL,
    CONSTRAINT [PK_orders] PRIMARY KEY CLUSTERED ([order_id] ASC),
    CONSTRAINT [FK_orders_channel] FOREIGN KEY ([channel_id]) REFERENCES [ref].[order_channels] ([channel_id]),
    CONSTRAINT [FK_orders_customer] FOREIGN KEY ([customer_id]) REFERENCES [marketplace].[customers] ([customer_id]),
    CONSTRAINT [FK_orders_status] FOREIGN KEY ([status_id]) REFERENCES [ref].[order_statuses] ([status_id])
);


GO

CREATE NONCLUSTERED INDEX [IX_orders_customer]
    ON [sales].[orders]([customer_id] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_orders_purchased_at]
    ON [sales].[orders]([purchased_at] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_orders_status]
    ON [sales].[orders]([status_id] ASC);


GO

