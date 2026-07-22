IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NextOfKin')
BEGIN

    CREATE TABLE dbo.NextOfKin
    (
        [Id] INT IDENTITY(1, 1) NOT NULL,
        [xRefCode] [VARCHAR](100) NOT NULL,
        [FirstName] [VARCHAR](100) NULL,
        [LastName] [VARCHAR](100) NULL,
        [Relationship] [VARCHAR](100) NULL,
        [Mobile] [VARCHAR](100) NULL,
        [ImportedAt] DATETIME2
            DEFAULT GETDATE() NOT NULL,

        CONSTRAINT [PK_NextOfKin]
            PRIMARY KEY CLUSTERED ([ID] ASC)
    ) ON [PRIMARY];

END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.NextOfKin')
          AND name = 'IsPrimary'
)
BEGIN
    ALTER TABLE dbo.NextOfKin ADD IsPrimary BIT NULL;
END;

