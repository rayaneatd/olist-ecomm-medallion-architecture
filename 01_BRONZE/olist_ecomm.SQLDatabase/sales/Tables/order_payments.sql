CREATE TABLE [sales].[order_payments] (
    [order_id]          CHAR (32)       NOT NULL,
    [payment_seq]       TINYINT         NOT NULL,
    [payment_method_id] TINYINT         NOT NULL,
    [installments]      TINYINT         DEFAULT ((1)) NOT NULL,
    [payment_value]     DECIMAL (10, 2) NOT NULL,
    CONSTRAINT [PK_order_payments] PRIMARY KEY CLUSTERED ([order_id] ASC, [payment_seq] ASC),
    CONSTRAINT [CHK_order_payments_installments] CHECK ([installments]>=(1)),
    CONSTRAINT [CHK_order_payments_value] CHECK ([payment_value]>=(0)),
    CONSTRAINT [FK_order_payments_method] FOREIGN KEY ([payment_method_id]) REFERENCES [ref].[payment_methods] ([payment_method_id]),
    CONSTRAINT [FK_order_payments_order] FOREIGN KEY ([order_id]) REFERENCES [sales].[orders] ([order_id])
);


GO

