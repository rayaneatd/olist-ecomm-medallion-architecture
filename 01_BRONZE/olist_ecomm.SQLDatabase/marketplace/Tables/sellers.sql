CREATE TABLE [marketplace].[sellers] (
    [seller_id]       CHAR (32)     NOT NULL,
    [zip_code_prefix] CHAR (5)      NULL,
    [seller_city]     NVARCHAR (80) NULL,
    [seller_state]    CHAR (2)      NULL,
    [onboarded_at]    DATETIME2 (0) DEFAULT (sysutcdatetime()) NOT NULL,
    [deleted_at]      DATETIME2 (0) NULL,
    CONSTRAINT [PK_sellers] PRIMARY KEY CLUSTERED ([seller_id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_sellers_state]
    ON [marketplace].[sellers]([seller_state] ASC);


GO

