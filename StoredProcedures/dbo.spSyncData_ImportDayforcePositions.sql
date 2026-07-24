CREATE OR ALTER PROCEDURE dbo.spSyncData_ImportDayforcePositions @CsvContent NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Columns extracted by index from the CSV:
    --  [4]  Budget FTE                  -> FTE
    --  [6]  Ledger code                 -> LedgerCode
    -- [10]  Occupant name               -> OccupantName
    -- [11]  Position number             -> PositionNumber
    -- [12]  Position name               -> PositionName
    -- [24]  Position detail effective end   -> PositionDetailEffectiveEnd
    -- [25]  Position detail effective start -> PositionDetailEffectiveStart
    -- [41]  Position status             -> PositionStatus
    -- [42]  Position status effective end   -> PositionStatusEffectiveEnd
    -- [43]  Position status effective start -> PositionStatusEffectiveStart
    -- [45]  Position reference code     -> PositionReferenceCode
    -- [46]  Supports interim occupancy  -> SupportsInterimOccupancy
    -- [48]  JobAssignmentReferenceCode  -> Job Assignment Reference Code
    -- [49]  LocationReferenceCode       -> Location Reference Code

    CREATE TABLE #Staging
    (
        PositionNumber NVARCHAR(100),
        PositionName NVARCHAR(300),
        OccupantName NVARCHAR(200),
        FTE VARCHAR(50),
        LedgerCode NVARCHAR(50),
        PositionDetailEffectiveStart VARCHAR(50),
        PositionDetailEffectiveEnd VARCHAR(50),
        PositionStatus NVARCHAR(50),
        PositionStatusEffectiveStart VARCHAR(50),
        PositionStatusEffectiveEnd VARCHAR(50),
        PositionReferenceCode NVARCHAR(100),
        SupportsInterimOccupancy VARCHAR(10),
        JobAssignmentReferenceCode NVARCHAR(300),
        LocationReferenceCode NVARCHAR(300)
    );

    DECLARE @Line NVARCHAR(MAX);
    DECLARE @RowNum INT = 0;
    DECLARE @Json NVARCHAR(MAX);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT value
    FROM STRING_SPLIT(REPLACE(@CsvContent, CHAR(13) + CHAR(10), CHAR(10)), CHAR(10))
    WHERE LEN(TRIM(value)) > 0;

    OPEN cur;
    FETCH NEXT FROM cur
    INTO @Line;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RowNum = @RowNum + 1;

        -- Skip header row
        IF @RowNum > 1
        BEGIN
            SET @Json = N'[' + @Line + N']';

            INSERT INTO #Staging
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
                PositionReferenceCode,
                SupportsInterimOccupancy,
                JobAssignmentReferenceCode,
                LocationReferenceCode
            )
            SELECT JSON_VALUE(@Json, '$[11]'), -- Position number
                   JSON_VALUE(@Json, '$[12]'), -- Position name
                   JSON_VALUE(@Json, '$[10]'), -- Occupant name
                   JSON_VALUE(@Json, '$[4]'),  -- Budget FTE
                   JSON_VALUE(@Json, '$[6]'),  -- Ledger code
                   JSON_VALUE(@Json, '$[25]'), -- Position detail effective start
                   JSON_VALUE(@Json, '$[24]'), -- Position detail effective end
                   JSON_VALUE(@Json, '$[41]'), -- Position status
                   JSON_VALUE(@Json, '$[43]'), -- Position status effective start
                   JSON_VALUE(@Json, '$[42]'), -- Position status effective end
                   JSON_VALUE(@Json, '$[45]'), -- Position reference code
                   JSON_VALUE(@Json, '$[46]'), -- Supports interim occupancy
                   JSON_VALUE(@Json, '$[48]'), -- Job Assignment Reference Code
                   JSON_VALUE(@Json, '$[49]'); -- Location Reference Code
        END;

        FETCH NEXT FROM cur
        INTO @Line;
    END;

    CLOSE cur;
    DEALLOCATE cur;

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
        LocationReferenceCode,
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
           CASE
               WHEN NULLIF(TRIM(PositionDetailEffectiveStart), '') IS NULL THEN
                   NULL
               ELSE
                   CONVERT(DATE, PositionDetailEffectiveStart, 103)
           END,
           CASE
               WHEN NULLIF(TRIM(PositionDetailEffectiveEnd), '') IS NULL THEN
                   NULL
               ELSE
                   CONVERT(DATE, PositionDetailEffectiveEnd, 103)
           END,
           NULLIF(TRIM(PositionStatus), ''),
           CASE
               WHEN NULLIF(TRIM(PositionStatusEffectiveStart), '') IS NULL THEN
                   NULL
               ELSE
                   CONVERT(DATE, PositionStatusEffectiveStart, 103)
           END,
           CASE
               WHEN NULLIF(TRIM(PositionStatusEffectiveEnd), '') IS NULL THEN
                   NULL
               ELSE
                   CONVERT(DATE, PositionStatusEffectiveEnd, 103)
           END,
           CASE
               WHEN LOWER(TRIM(SupportsInterimOccupancy)) = 'true' THEN
                   1
               ELSE
                   0
           END,
           NULLIF(TRIM(PositionReferenceCode), ''),
           NULLIF(TRIM(JobAssignmentReferenceCode), ''),
           NULLIF(TRIM(LocationReferenceCode), ''),
           GETDATE()
    FROM #Staging
    WHERE NULLIF(TRIM(PositionNumber), '') IS NOT NULL;

    DROP TABLE #Staging;
END;
