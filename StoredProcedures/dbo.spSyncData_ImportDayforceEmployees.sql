CREATE OR ALTER PROCEDURE dbo.spSyncData_ImportDayforceEmployees
    @CsvContent NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Staging table for parsed rows
    CREATE TABLE #Staging
    (
        EmployeeReferenceCode       VARCHAR(100),
        EmployeeDisplayName         VARCHAR(200),
        PositionNumber              VARCHAR(100),
        PositionName                VARCHAR(300),
        LocationName                VARCHAR(200),
        FTEValue                    VARCHAR(50),
        WorkAssignmentEffectiveStart VARCHAR(50),
        WorkAssignmentEffectiveEnd   VARCHAR(50),
        EmployeeEmployeeId          VARCHAR(100),
        TerminationDate             VARCHAR(50)
    );

    -- Parse the CSV line by line using STRING_SPLIT on newlines,
    -- then split each line into columns using a JSON array trick.
    -- We skip the header row (row where first token = 'Employee reference code').
    DECLARE @Line       NVARCHAR(MAX);
    DECLARE @RowNum     INT = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT value
        FROM STRING_SPLIT(REPLACE(@CsvContent, CHAR(13) + CHAR(10), CHAR(10)), CHAR(10))
        WHERE LEN(TRIM(value)) > 0;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Line;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RowNum = @RowNum + 1;

        -- Skip header row
        IF @RowNum > 1
        BEGIN
            -- Strip surrounding quotes from each field and split by ","
            -- Convert "f1","f2",... into a JSON array ["f1","f2",...] then parse
            DECLARE @Json NVARCHAR(MAX) = '[' + @Line + ']';

            -- Replace the ","  delimiter with ],[ while keeping quoted values intact
            -- Because values are already quoted with double-quotes in the CSV we can
            -- leverage OPENJSON after transforming the line.
            -- Simpler approach: use OPENJSON on a wrapped array.
            INSERT INTO #Staging
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
                TerminationDate
            )
            SELECT
                JSON_VALUE(@Json, '$[0]'),
                JSON_VALUE(@Json, '$[1]'),
                JSON_VALUE(@Json, '$[2]'),
                JSON_VALUE(@Json, '$[3]'),
                JSON_VALUE(@Json, '$[4]'),
                JSON_VALUE(@Json, '$[5]'),
                JSON_VALUE(@Json, '$[6]'),
                JSON_VALUE(@Json, '$[7]'),
                JSON_VALUE(@Json, '$[8]'),
                JSON_VALUE(@Json, '$[9]');
        END

        FETCH NEXT FROM cur INTO @Line;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Truncate destination and insert parsed rows
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
        CASE WHEN NULLIF(TRIM(FTEValue), '') IS NULL THEN NULL ELSE CAST(FTEValue AS DECIMAL(5,2)) END,
        CASE WHEN NULLIF(TRIM(WorkAssignmentEffectiveStart), '') IS NULL THEN NULL
             ELSE CONVERT(DATE, WorkAssignmentEffectiveStart, 103) END,
        CASE WHEN NULLIF(TRIM(WorkAssignmentEffectiveEnd), '') IS NULL THEN NULL
             ELSE CONVERT(DATE, WorkAssignmentEffectiveEnd, 103) END,
        EmployeeEmployeeId,
        CASE WHEN NULLIF(TRIM(TerminationDate), '') IS NULL THEN NULL
             ELSE CONVERT(DATE, TerminationDate, 103) END,
        GETDATE()
    FROM #Staging
    WHERE NULLIF(TRIM(EmployeeReferenceCode), '') IS NOT NULL
      AND ISNUMERIC(EmployeeReferenceCode) = 1;

    DROP TABLE #Staging;
END;
