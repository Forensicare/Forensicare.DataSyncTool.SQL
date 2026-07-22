
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BulkUploadData')
BEGIN
    CREATE TABLE dbo.BulkUploadData
    (
        Id INT IDENTITY(1, 1) PRIMARY KEY,
        CreatedAt DATETIME
            DEFAULT GETDATE() NOT NULL,
        XrefCode VARCHAR(100) NOT NULL,
        DataType VARCHAR(100) NOT NULL,
        Value VARCHAR(100) NOT NULL,
        UploadCompletedDate DATETIME NULL,
    );
END;
