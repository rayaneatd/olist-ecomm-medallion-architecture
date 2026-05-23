CREATE TABLE [catalog].[product_categories] (
    [category_id]        SMALLINT      IDENTITY (1, 1) NOT NULL,
    [category_code]      VARCHAR (60)  NOT NULL,
    [category_label]     NVARCHAR (80) NOT NULL,
    [parent_category_id] SMALLINT      NULL,
    CONSTRAINT [PK_product_categories] PRIMARY KEY CLUSTERED ([category_id] ASC),
    CONSTRAINT [FK_product_category_parent] FOREIGN KEY ([parent_category_id]) REFERENCES [catalog].[product_categories] ([category_id]),
    CONSTRAINT [UQ_product_categories_code] UNIQUE NONCLUSTERED ([category_code] ASC)
);


GO

