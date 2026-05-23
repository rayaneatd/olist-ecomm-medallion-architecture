CREATE TABLE [ref].[payment_methods] (
    [payment_method_id] TINYINT       NOT NULL,
    [method_code]       VARCHAR (30)  NOT NULL,
    [method_label]      NVARCHAR (60) NOT NULL,
    [is_active]         BIT           DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_payment_methods] PRIMARY KEY CLUSTERED ([payment_method_id] ASC),
    CONSTRAINT [UQ_payment_methods_code] UNIQUE NONCLUSTERED ([method_code] ASC)
);


GO

