IF NOT EXISTS
(
    SELECT *
    FROM sys.tables
    WHERE name = 'DayforceEmployeeProcessing'
)
BEGIN

    CREATE TABLE dbo.DayforceEmployeeProcessing
    (
        [xrefCode] [VARCHAR](100) NOT NULL,
        [BirthDate] [DATE] NOT NULL,
        [EmployeeLatestUpdatedTimestamp] [DATETIME] NOT NULL,
        [DisplayName] [VARCHAR](200) NOT NULL,
        [FirstName] [VARCHAR](100) NOT NULL,
        [LastName] [VARCHAR](100) NOT NULL,
        [Suffix] [VARCHAR](100) NULL,
        [CreateDate] [DATETIME] NOT NULL,
        [UpdateDate] [DATETIME] NULL,
        [BirthCountry] [VARCHAR](200) NULL,
        [RegisteredDisabled] [BIT] NOT NULL,
        [StartDate] [DATETIME] NOT NULL,
        [Title] [VARCHAR](100) NULL,
        [PreviousLastName] [VARCHAR](100) NULL,
        [CommonName] VARCHAR(100) NULL,
        [Nationality] VARCHAR(100) NULL,
        [Gender] VARCHAR(50) NULL,
        [PreferredLastName] VARCHAR(100) NULL,
        [MiddleName] VARCHAR(100) NULL,
        [TaxFileNumber] VARCHAR(25) NULL,
        [PayClass] VARCHAR(50) NULL,
        [BankAccountNumber] VARCHAR(50) NULL,
        [Address1] VARCHAR(100) NULL,
        [Address2] VARCHAR(100) NULL,
        [City] VARCHAR(100) NULL,
        [PostalCode] VARCHAR(100) NULL,
        [Country] VARCHAR(100) NULL,
        [State] VARCHAR(100) NULL,
        [Processing] [BIT] NOT NULL,
        CONSTRAINT [PK_Employee]
            PRIMARY KEY CLUSTERED ([xrefCode] ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
                 ) ON [PRIMARY]
    ) ON [PRIMARY];

    ALTER TABLE dbo.DayforceEmployeeProcessing
    ADD CONSTRAINT [DF_Employee_CreateDate]
        DEFAULT (GETDATE()) FOR [CreateDate];

    ALTER TABLE dbo.DayforceEmployeeProcessing
    ADD CONSTRAINT [DF_Employee_Processing]
        DEFAULT ((0)) FOR [Processing];

END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.DayforceEmployeeProcessing')
          AND name = 'IndigenousStatus'
)
BEGIN
    ALTER TABLE dbo.DayforceEmployeeProcessing
    ADD IndigenousStatus VARCHAR(100) NULL;
END;
