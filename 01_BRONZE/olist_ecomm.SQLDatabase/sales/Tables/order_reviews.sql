CREATE TABLE [sales].[order_reviews] (
    [review_id]          CHAR (32)       NOT NULL,
    [order_id]           CHAR (32)       NOT NULL,
    [satisfaction_score] TINYINT         NOT NULL,
    [comment_message]    NVARCHAR (1000) NULL,
    [created_at]         DATETIME2 (0)   NOT NULL,
    [responded_at]       DATETIME2 (0)   NULL,
    CONSTRAINT [PK_order_reviews] PRIMARY KEY CLUSTERED ([review_id] ASC),
    CONSTRAINT [CHK_order_reviews_score] CHECK ([satisfaction_score]>=(0) AND [satisfaction_score]<=(100)),
    CONSTRAINT [FK_order_reviews_order] FOREIGN KEY ([order_id]) REFERENCES [sales].[orders] ([order_id])
);


GO

CREATE NONCLUSTERED INDEX [IX_order_reviews_order]
    ON [sales].[order_reviews]([order_id] ASC);


GO

