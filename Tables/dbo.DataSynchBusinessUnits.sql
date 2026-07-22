IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DataSynchBusinessUnits')
BEGIN
    CREATE TABLE dbo.DataSynchBusinessUnits
    (
        BusinessUnitLedgerCode VARCHAR(100) NULL,
        BusinessUnitName VARCHAR(200) NULL,
        BusinessUnitReferenceCode VARCHAR(400) NULL,
        BusinessUnitActivationDate DATE NULL,
        BusinessUnitDeActivationDate DATE NULL,
        ImportedAt DATETIME2
            DEFAULT GETDATE() NOT NULL
    );
END;
