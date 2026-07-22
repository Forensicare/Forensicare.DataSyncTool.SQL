IF NOT EXISTS
(
    SELECT *
    FROM sys.tables
    WHERE name = 'DayforceEmployeeContact'
)
BEGIN

    CREATE TABLE dbo.DayforceEmployeeContact
    (
        [PersonContactID] [INT] NOT NULL,
        [xrefCode] [VARCHAR](100) NOT NULL,
        [ContactInformationType_XRefCode] [VARCHAR](100) NOT NULL,
        [Value] [VARCHAR](200) NOT NULL,
        [LastModifiedTimestamp] [DATETIME] NOT NULL,
        [Created] [DATETIME] NOT NULL,
        [UpdateDate] [DATETIME] NULL,
        CONSTRAINT [PK_EmployeeContact]
            PRIMARY KEY CLUSTERED ([PersonContactID] ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
                 ) ON [PRIMARY]
    ) ON [PRIMARY];


    ALTER TABLE dbo.DayforceEmployeeContact
    ADD CONSTRAINT [DF_EmployeeContact_Created]
        DEFAULT (GETDATE()) FOR [Created];


    ALTER TABLE dbo.DayforceEmployeeContact WITH CHECK
    ADD CONSTRAINT [FK_EmployeeContact_Employee]
        FOREIGN KEY ([xrefCode])
        REFERENCES dbo.DayforceEmployeeProcessing ([xrefCode]);


    ALTER TABLE dbo.DayforceEmployeeContact CHECK CONSTRAINT [FK_EmployeeContact_Employee];



END;