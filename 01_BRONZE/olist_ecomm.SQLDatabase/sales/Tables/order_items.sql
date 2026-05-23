CREATE TABLE [sales].[order_items] (
    [order_id]          CHAR (32)       NOT NULL,
    [order_item_seq]    TINYINT         NOT NULL,
    [product_id]        CHAR (32)       NOT NULL,
    [seller_id]         CHAR (32)       NOT NULL,
    [shipping_limit_at] DATETIME2 (0)   NOT NULL,
    [unit_price]        DECIMAL (10, 2) NOT NULL,
    [freight_value]     DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_order_items] PRIMARY KEY CLUSTERED ([order_id] ASC, [order_item_seq] ASC),
    CONSTRAINT [CHK_order_items_freight] CHECK ([freight_value]>=(0)),
    CONSTRAINT [CHK_order_items_price] CHECK ([unit_price]>=(0)),
    CONSTRAINT [FK_order_items_order] FOREIGN KEY ([order_id]) REFERENCES [sales].[orders] ([order_id]),
    CONSTRAINT [FK_order_items_product] FOREIGN KEY ([product_id]) REFERENCES [catalog].[products] ([product_id]),
    CONSTRAINT [FK_order_items_seller] FOREIGN KEY ([seller_id]) REFERENCES [marketplace].[sellers] ([seller_id])
);


GO

CREATE NONCLUSTERED INDEX [IX_order_items_product]
    ON [sales].[order_items]([product_id] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_order_items_seller]
    ON [sales].[order_items]([seller_id] ASC);


GO

