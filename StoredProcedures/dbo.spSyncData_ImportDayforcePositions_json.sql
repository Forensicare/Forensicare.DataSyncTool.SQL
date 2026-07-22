CREATE OR ALTER PROCEDURE dbo.spSyncData_ImportDayforcePositions_json @JsonContent NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.DataSynchPositions;

    INSERT INTO dbo.DataSynchPositions
    (
        PositionNumber,
        PositionName,
        OccupantName,
        FTE,
        LedgerCode,
        PositionDetailEffectiveStart,
        PositionDetailEffectiveEnd,
        PositionStatus,
        PositionStatusEffectiveStart,
        PositionStatusEffectiveEnd,
        SupportsInterimOccupancy,
        PositionReferenceCode,
        JobAssignmentReferenceCode,
        ImportedAt
    )
    SELECT PositionNumber,
           PositionName,
           NULLIF(TRIM(OccupantName), ''),
           CASE
               WHEN NULLIF(TRIM(FTE), '') IS NULL THEN
                   NULL
               ELSE
                   CAST(FTE AS DECIMAL(5, 2))
           END,
           NULLIF(TRIM(LedgerCode), ''),
           -- Dates arrive as ISO 8601 (2024-12-29T00:00:00); strip the time part before casting
           CASE
               WHEN NULLIF(TRIM(PositionDetailEffectiveStart), '') IS NULL THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(PositionDetailEffectiveStart), 10) AS DATE)
           END,
           CASE
               WHEN NULLIF(TRIM(PositionDetailEffectiveEnd), '') IS NULL THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(PositionDetailEffectiveEnd), 10) AS DATE)
           END,
           NULLIF(TRIM(PositionStatus), ''),
           CASE
               WHEN NULLIF(TRIM(PositionStatusEffectiveStart), '') IS NULL THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(PositionStatusEffectiveStart), 10) AS DATE)
           END,
           CASE
               WHEN NULLIF(TRIM(PositionStatusEffectiveEnd), '') IS NULL THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(PositionStatusEffectiveEnd), 10) AS DATE)
           END,
           CASE
               WHEN LOWER(TRIM(SupportsInterimOccupancy)) = 'true' THEN
                   1
               ELSE
                   0
           END,
           NULLIF(TRIM(PositionReferenceCode), ''),
           NULLIF(TRIM(JobAssignmentReferenceCode), ''),
           GETDATE()
    FROM OPENJSON(@JsonContent)
         WITH
         (
             PositionNumber NVARCHAR(100) '$."Position number"',
             PositionName NVARCHAR(300) '$."Position name"',
             OccupantName NVARCHAR(200) '$."Occupant name"',
             FTE VARCHAR(50) '$."Budget FTE"',
             LedgerCode NVARCHAR(50) '$."Ledger code"',
             PositionDetailEffectiveStart VARCHAR(50) '$."Position detail effective start"',
             PositionDetailEffectiveEnd VARCHAR(50) '$."Position detail effective end"',
             PositionStatus NVARCHAR(50) '$."Position status"',
             PositionStatusEffectiveStart VARCHAR(50) '$."Position status effective start"',
             PositionStatusEffectiveEnd VARCHAR(50) '$."Position status effective end"',
             SupportsInterimOccupancy VARCHAR(10) '$."Supports interim occupancy"',
             PositionReferenceCode NVARCHAR(100) '$."Position reference code"',
             JobAssignmentReferenceCode NVARCHAR(300) '$."Job assignment reference code"'
         )
    WHERE NULLIF(TRIM(PositionNumber), '') IS NOT NULL;

END;
