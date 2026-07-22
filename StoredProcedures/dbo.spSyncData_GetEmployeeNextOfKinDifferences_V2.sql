-- =============================================
-- Procedure:    dbo.spSyncData_GetEmployeeNextOfKinDifferences_V2
-- Description:  Identifies employees whose next-of-kin records differ between the
--               staging source (dbo.Syn_NextOfKin) and the Dayforce target
--               (dbo.NextOfKin). Differences are detected on the mobile phone
--               number (after stripping spaces). Results are returned as two
--               parallel paged result sets — one from Dayforce and one from the
--               staging source — so the caller can compare them side-by-side.
--               The total number of distinct differing employees is returned via
--               the OUTPUT parameter @RecordCount.
--
-- Parameters:
--   @Page           INT     - 1-based page number to return (default: 1)
--   @RecordsPerPage INT     - Number of employees per page   (default: 50)
--   @RecordCount    INT OUT - Total count of distinct employees with differences
--
-- Result Sets:
--   #1 - Dayforce (dbo.NextOfKin) records for the requested page:
--          xRefCode, FirstName, LastName, Relationship, Mobile (spaces removed), IsPrimary
--   #2 - Staging (dbo.Syn_NextOfKin) records matched to result set #1:
--          EmployeeCode, FirstNames, LastName, RelationType, MobilePhone (spaces removed)
--
-- Notes:
--   - Employee codes in Dayforce are prefixed with '1' relative to the staging
--     source, e.g. Dayforce xRefCode '1ABC' maps to staging EmployeeCode 'ABC'.
--   - Mobile number comparison is case-insensitive (Latin1_General_CI_AS collation)
--     and ignores all space characters on both sides.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeNextOfKinDifferences_V2
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1
        SET @Page = 1;
    IF @RecordsPerPage < 1
        SET @RecordsPerPage = 50;

    -- Step 1: Find distinct Dayforce xRefCodes where at least one next-of-kin row
    --         has no matching mobile number in the staging source.
    --         The '1' + EmployeeCode join maps staging codes to Dayforce xRefCodes.
    SELECT DISTINCT
           DF.xRefCode
    INTO #DistinctDayforceRecords
    FROM dbo.Syn_NextOfKin PG
        INNER JOIN dbo.NextOfKin DF
            ON DF.xRefCode = '1' + PG.EmployeeCode COLLATE Latin1_General_CI_AS
    WHERE NOT EXISTS
    (
        -- A match exists only when both mobile numbers are identical after
        -- stripping spaces; if no such row is found the employee is flagged.
        SELECT 1
        FROM dbo.NextOfKin nk2
        WHERE nk2.xRefCode = DF.xRefCode
              AND dbo.fn_FormatMobileNumber(nk2.Mobile) = dbo.fn_FormatMobileNumber(PG.MobilePhone)COLLATE Latin1_General_CI_AS
    )
    ORDER BY DF.xRefCode DESC;

    -- Step 2: Capture the total number of distinct differing employees for the caller.
    SELECT @RecordCount = COUNT(*)
    FROM #DistinctDayforceRecords;

    -- Step 3: Slice the full result set down to the requested page.
    SELECT xRefCode
    INTO #PagedDayforceRecords
    FROM #DistinctDayforceRecords
    ORDER BY xRefCode DESC OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    -- Step 4: Retrieve all Dayforce next-of-kin rows for the paged employees.
    --         Mobile spaces are stripped here so the caller receives clean data.
    SELECT DF.xRefCode,
           DF.FirstName,
           DF.LastName,
           DF.Relationship,
           REPLACE(ISNULL(DF.Mobile, ''), ' ', '') AS Mobile,
           DF.IsPrimary
    INTO #FinalDayforceRecords
    FROM dbo.NextOfKin DF
        INNER JOIN #PagedDayforceRecords x
            ON x.xRefCode = DF.xRefCode
    ORDER BY DF.xRefCode DESC;

    -- Result set 1: Dayforce records for the current page.
    SELECT xRefCode,
           FirstName,
           LastName,
           Relationship,
           Mobile,
           IsPrimary
    FROM #FinalDayforceRecords
    ORDER BY xRefCode DESC;

    -- Result set 2: Corresponding staging source records, joined back via the
    --               '1' + EmployeeCode convention used throughout this procedure.
    SELECT PG.EmployeeCode,
           PG.FirstNames,
           PG.LastName,
           PG.RelationType,
           REPLACE(ISNULL(PG.MobilePhone, ''), ' ', '') AS MobilePhone
    FROM dbo.Syn_NextOfKin PG
        INNER JOIN #FinalDayforceRecords DF
            ON DF.xRefCode = '1' + PG.EmployeeCode COLLATE Latin1_General_CI_AS
    ORDER BY PG.EmployeeCode DESC;

    -- Cleanup temporary tables.
    DROP TABLE IF EXISTS #DistinctDayforceRecords;
    DROP TABLE IF EXISTS #PagedDayforceRecords;
    DROP TABLE IF EXISTS #FinalDayforceRecords;

END;
GO
