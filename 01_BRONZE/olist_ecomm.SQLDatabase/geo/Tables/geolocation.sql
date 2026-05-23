CREATE TABLE [geo].[geolocation] (
    [geo_id]          INT             IDENTITY (1, 1) NOT NULL,
    [zip_code_prefix] CHAR (5)        NOT NULL,
    [geo_lat]         DECIMAL (10, 7) NOT NULL,
    [geo_lng]         DECIMAL (10, 7) NOT NULL,
    [city]            NVARCHAR (80)   NOT NULL,
    [state_code]      CHAR (2)        NOT NULL,
    CONSTRAINT [PK_geolocation] PRIMARY KEY CLUSTERED ([geo_id] ASC),
    CONSTRAINT [UQ_geolocation_zip_coords] UNIQUE NONCLUSTERED ([zip_code_prefix] ASC, [geo_lat] ASC, [geo_lng] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_geolocation_zip]
    ON [geo].[geolocation]([zip_code_prefix] ASC);


GO

