CREATE TABLE [ref].[order_statuses] (
    [status_id]    TINYINT       NOT NULL,
    [status_code]  VARCHAR (20)  NOT NULL,
    [status_label] NVARCHAR (50) NOT NULL,
    [is_terminal]  BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_order_statuses] PRIMARY KEY CLUSTERED ([status_id] ASC),
    CONSTRAINT [UQ_order_statuses_code] UNIQUE NONCLUSTERED ([status_code] ASC)
);


GO

