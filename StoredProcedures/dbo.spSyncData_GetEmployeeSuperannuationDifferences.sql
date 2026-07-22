CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeSuperannuationDifferences
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

    -- Get a list of Superannuation records from PayGlobal that can be migrated to Dayforce
    SELECT DF.xRefCode
    INTO #DistinctDayforceRecords
    FROM dbo.Syn_Superannuation PG
        INNER JOIN dbo.Superannuation DF
            ON DF.xRefCode = '1' + PG.EmployeeCode COLLATE Latin1_General_CI_AS
    WHERE PG.EndDate IS NULL
    ORDER BY PG.EmployeeCode,
             PG.StartDate DESC;

    -- Step 2: Capture the total number of distinct differing employees for the caller.
    SELECT @RecordCount = COUNT(*)
    FROM #DistinctDayforceRecords;


    -- Step 3: Slice the full result set down to the requested page.
    SELECT xRefCode
    INTO #PagedDayforceRecords
    FROM #DistinctDayforceRecords
    ORDER BY xRefCode DESC OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    -- Step 4: Get Dayforce Superannuation records

    SELECT DF.xRefCode,
           DF.EffectiveStart,
           DF.EffectiveEnd,
           DF.MembershipNumber,
           DF.SuperannuationContributionCalcValue,
           DF.IsActive,
           DF.SuperannuationContributionType,
           DF.SuperannuationType,
           DF.SuperannuationContributionCalculationType
    INTO #FinalDayforceRecords
    FROM dbo.Superannuation DF
        INNER JOIN #PagedDayforceRecords x
            ON x.xRefCode = DF.xRefCode
    ORDER BY DF.xRefCode DESC;


    -- Result set 1: Dayforce Records
    SELECT DF.xRefCode,
           DF.EffectiveStart,
           DF.EffectiveEnd,
           DF.MembershipNumber,
           DF.SuperannuationContributionCalcValue,
           DF.IsActive,
           DF.SuperannuationContributionType,
           DF.SuperannuationType,
           DF.SuperannuationContributionCalculationType
    FROM #FinalDayforceRecords DF
    ORDER BY xRefCode DESC;

    -- Result set 2: 

    SELECT PG.EmployeeCode,
           PG.StartDate,
           PG.EndDate,
           PG.Active,
           PG.MemberID,
           PG.EmployerPercent,
           PG.EmployerAmount,
           PG.EmployeePercent,
           PG.EmployeeAmount
    FROM dbo.Syn_Superannuation PG
        INNER JOIN #FinalDayforceRecords DF
            ON DF.xRefCode = '1' + PG.EmployeeCode COLLATE Latin1_General_CI_AS
    ORDER BY PG.EmployeeCode DESC;

    -- Cleanup temporary tables.
    DROP TABLE IF EXISTS #DistinctDayforceRecords;
    DROP TABLE IF EXISTS #PagedDayforceRecords;
    DROP TABLE IF EXISTS #FinalDayforceRecords;

END;