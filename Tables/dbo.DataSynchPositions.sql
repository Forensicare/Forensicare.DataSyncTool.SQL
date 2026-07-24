
-- Create staging table if it does not exist
IF OBJECT_ID('dbo.DataSynchPositions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DataSynchPositions
    (
        PositionNumber NVARCHAR(100) NOT NULL,
        PositionName NVARCHAR(300),
        OccupantName NVARCHAR(200) NULL,
        FTE DECIMAL(5, 2),
        LedgerCode NVARCHAR(50),
        PositionDetailEffectiveStart DATE,
        PositionDetailEffectiveEnd DATE,
        PositionStatus NVARCHAR(50),
        PositionStatusEffectiveStart DATE,
        PositionStatusEffectiveEnd DATE,
        SupportsInterimOccupancy BIT,
        PositionReferenceCode NVARCHAR(100),
        ImportedAt DATETIME2
            DEFAULT GETDATE()
    );
END;

-- Add new columns if they do not exist
IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.DataSynchPositions')
          AND name = 'JobAssignmentReferenceCode'
)
BEGIN
    ALTER TABLE dbo.DataSynchPositions
    ADD JobAssignmentReferenceCode NVARCHAR(300);
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.DataSynchPositions')
          AND name = 'LocationReferenceCode'
)
BEGIN
    ALTER TABLE dbo.DataSynchPositions
    ADD LocationReferenceCode NVARCHAR(300);
END;