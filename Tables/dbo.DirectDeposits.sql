IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DirectDeposits')
BEGIN
    CREATE TABLE dbo.DirectDeposits
    (
        xrefCode VARCHAR(100) NOT NULL,
        AccountNumber VARCHAR(100) NULL,
        EffectiveStart DATE NULL,
        ImportedAt DATETIME2
            DEFAULT GETDATE() NOT NULL
    );
END;
