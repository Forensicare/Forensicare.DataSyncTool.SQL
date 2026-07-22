-- Create Super table if it does not exist
IF OBJECT_ID('dbo.Superannuation', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.Superannuation
    (
        [xRefCode] VARCHAR(100) NOT NULL,
        [EffectiveStart] DATE NULL,
        [EffectiveEnd] DATE NULL,
        [MembershipNumber] VARCHAR(100) NULL,
        [SuperannuationContributionCalcValue] DECIMAL(10, 2) NULL,
        [IsActive] BIT NULL,
        [SuperannuationContributionType] VARCHAR(100) NULL,
        [SuperannuationType] VARCHAR(100) NULL,
        [SuperannuationContributionCalculationType] VARCHAR(100) NULL,
        [ImportedAt] DATETIME2 NOT NULL
            DEFAULT GETDATE(),
        CONSTRAINT [PK_Super]
            PRIMARY KEY CLUSTERED ([xRefCode] ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
                 ) ON [PRIMARY]
    ) ON [PRIMARY];

END;
