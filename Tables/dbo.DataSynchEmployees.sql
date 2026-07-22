

-- Create staging table if it does not exist
IF OBJECT_ID('dbo.DataSynchEmployees', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DataSynchEmployees
    (
        EmployeeReferenceCode INT NOT NULL,
        EmployeeDisplayName VARCHAR(200) NOT NULL,
        PositionNumber VARCHAR(100) NULL,
        PositionName VARCHAR(300),
        LocationName VARCHAR(200),
        FTEValue DECIMAL(5, 2),
        WorkAssignmentEffectiveStart DATE,
        WorkAssignmentEffectiveEnd DATE,
        EmployeeEmployeeId VARCHAR(100),
        TerminationDate DATE,
        ImportedAt DATETIME2
            DEFAULT GETDATE(),
        ExcludeFromOrphanedEmployeesReport BIT NOT NULL
            DEFAULT 0
    );
END;

-- Add new columns if they do not exist
IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.DataSynchEmployees')
          AND name = 'ExcludeFromOrphanedEmployeesReport'
)
BEGIN
    ALTER TABLE dbo.DataSynchEmployees
    ADD ExcludeFromOrphanedEmployeesReport BIT NOT NULL
            DEFAULT 0;
END;

