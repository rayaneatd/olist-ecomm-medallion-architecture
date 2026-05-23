CREATE TABLE [ref].[order_channels] (
    [channel_id]    TINYINT       NOT NULL,
    [channel_code]  VARCHAR (20)  NOT NULL,
    [channel_label] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_order_channels] PRIMARY KEY CLUSTERED ([channel_id] ASC),
    CONSTRAINT [UQ_order_channels_code] UNIQUE NONCLUSTERED ([channel_code] ASC)
);


GO

