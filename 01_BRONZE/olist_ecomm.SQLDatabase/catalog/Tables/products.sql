CREATE TABLE [catalog].[products] (
    [product_id]                 CHAR (32)     NOT NULL,
    [category_id]                SMALLINT      NULL,
    [product_name_length]        SMALLINT      NULL,
    [product_description_length] INT           NULL,
    [photo_count]                TINYINT       NULL,
    [weight_g]                   INT           NULL,
    [length_cm]                  SMALLINT      NULL,
    [height_cm]                  SMALLINT      NULL,
    [width_cm]                   SMALLINT      NULL,
    [created_at]                 DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_products] PRIMARY KEY CLUSTERED ([product_id] ASC),
    CONSTRAINT [FK_products_category] FOREIGN KEY ([category_id]) REFERENCES [catalog].[product_categories] ([category_id])
);


GO

CREATE NONCLUSTERED INDEX [IX_products_category]
    ON [catalog].[products]([category_id] ASC);


GO

