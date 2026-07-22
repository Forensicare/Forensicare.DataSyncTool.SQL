CREATE OR ALTER PROCEDURE dbo.spSyncData_ImportDayforceEmployees_json
    @JsonContent NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.DataSynchEmployees;

    INSERT INTO dbo.DataSynchEmployees
    (
        EmployeeReferenceCode,
        EmployeeDisplayName,
        PositionNumber,
        PositionName,
        LocationName,
        FTEValue,
        WorkAssignmentEffectiveStart,
        WorkAssignmentEffectiveEnd,
        EmployeeEmployeeId,
        TerminationDate,
        ImportedAt
    )
    SELECT
        CAST(EmployeeReferenceCode AS INT),
        EmployeeDisplayName,
        PositionNumber,
        PositionName,
        LocationName,
        CASE
            WHEN NULLIF(TRIM(FTEValue), '') IS NULL
                 OR LOWER(TRIM(FTEValue)) = 'null' THEN
                NULL
            ELSE
                CAST(FTEValue AS DECIMAL(5, 2))
        END,
        -- Dates arrive as ISO 8601 (2025-05-07T00:00:00); strip the time part before casting
        CASE
            WHEN NULLIF(TRIM(WorkAssignmentEffectiveStart), '') IS NULL
                 OR LOWER(TRIM(WorkAssignmentEffectiveStart)) = 'null' THEN
                NULL
            ELSE
                CAST(LEFT(TRIM(WorkAssignmentEffectiveStart), 10) AS DATE)
        END,
        CASE
            WHEN NULLIF(TRIM(WorkAssignmentEffectiveEnd), '') IS NULL
                 OR LOWER(TRIM(WorkAssignmentEffectiveEnd)) = 'null' THEN
                NULL
            ELSE
                CAST(LEFT(TRIM(WorkAssignmentEffectiveEnd), 10) AS DATE)
        END,
        EmployeeEmployeeId,
        CASE
            WHEN NULLIF(TRIM(TerminationDate), '') IS NULL
                 OR LOWER(TRIM(TerminationDate)) = 'null' THEN
                NULL
            ELSE
                CAST(LEFT(TRIM(TerminationDate), 10) AS DATE)
        END,
        GETDATE()
    FROM OPENJSON(@JsonContent)
    WITH (
        EmployeeReferenceCode          VARCHAR(100)  '$."Employee reference code"',
        EmployeeDisplayName            VARCHAR(200)  '$."Employee display name"',
        PositionNumber                 VARCHAR(100)  '$."Position number"',
        PositionName                   VARCHAR(300)  '$."Position name"',
        LocationName                   VARCHAR(200)  '$."Location name"',
        FTEValue                       VARCHAR(50)   '$."FTE value"',
        WorkAssignmentEffectiveStart   VARCHAR(50)   '$."Work assignment effective start"',
        WorkAssignmentEffectiveEnd     VARCHAR(50)   '$."Work assignment effective end"',
        EmployeeEmployeeId             VARCHAR(100)  '$."Employee Employee Id"',
        TerminationDate                VARCHAR(50)   '$."Termination date"'
    )
    WHERE NULLIF(TRIM(EmployeeReferenceCode), '') IS NOT NULL
          AND ISNUMERIC(EmployeeReferenceCode) = 1;

END;
