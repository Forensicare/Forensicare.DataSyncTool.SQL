-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-
-- Description:	Get a list of payglobal waps
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetPayGlobalWAPS
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT,
    @Description NVARCHAR(255) = NULL,
    @WapCode NVARCHAR(255) = NULL,
    @ExcludeMatchingRecords BIT = 0,
    @ExcludeVacantPayGlobalPositionAndNoMatchingDayforceRecord BIT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    WITH ActivePayGlobalEmployees
    AS (SELECT a.WAPCode,
               STRING_AGG(TRIM('1' + e.EmployeeCode), ', ') WITHIN GROUP(ORDER BY e.EmployeeCode) AS EmployeeRefs
        FROM dbo.Syn_Appointment a
            INNER JOIN dbo.Syn_Employee e
                ON e.EmployeeCode = a.EmployeeCode
        WHERE a.Active = 1
        GROUP BY a.WAPCode),
         DayForceEmployees
    AS (SELECT LEFT(dp.PositionNumber, LEN(dp.PositionNumber) - 4) AS WAPCode,
               STRING_AGG(LTRIM(RTRIM(e.EmployeeReferenceCode)), ', ') WITHIN GROUP(ORDER BY e.EmployeeReferenceCode) AS EmployeeRefs
        FROM dbo.DataSynchPositions dp
            INNER JOIN dbo.DataSynchEmployees e
                ON e.PositionNumber = dp.PositionNumber
                   AND e.EmployeeDisplayName = dp.OccupantName
        WHERE LEN(dp.PositionNumber) >= 4
        GROUP BY LEFT(dp.PositionNumber, LEN(dp.PositionNumber) - 4))
    SELECT DISTINCT
           pg.WAPID,
           pg.WAPCode,
           pg.Description,
           pg.BudgetFTE,
           pg.CostCentreCode,
           pg.XWAPENDDATE,
           pg.ParentCode,
           pg.Status,
           pg.PositionCode,
           wa.Description AS WorkAreaDescription,
           apge.EmployeeRefs AS PayGlobalEmployeeRefs,
           dfe.EmployeeRefs AS DayforceEmployeeRefs
    INTO #FilteredWAPS
    FROM dbo.Syn_WAP pg
        LEFT JOIN dbo.Syn_WorkArea wa
            ON pg.WorkAreaCode = wa.WorkAreaCode
        LEFT JOIN ActivePayGlobalEmployees apge
            ON pg.WAPCode = apge.WAPCode COLLATE Latin1_General_CI_AS
        LEFT JOIN DayForceEmployees dfe
            ON pg.WAPCode = dfe.WAPCode COLLATE Latin1_General_CI_AS
    WHERE (
              pg.Status = 'Open'
              OR pg.XWAPENDDATE IS NULL
          )
          AND
          (
              @Description IS NULL
              OR pg.Description = @Description
          )
          AND
          (
              @WapCode IS NULL
              OR pg.WAPCode = @WapCode
          );


    IF @ExcludeMatchingRecords = 1
    BEGIN
        -- look for positions / assignments that match between Dayforce and Payglobal and remove them
        DELETE FROM #FilteredWAPS
        WHERE ISNULL(PayGlobalEmployeeRefs, '') = ISNULL(DayforceEmployeeRefs, '')COLLATE Latin1_General_CI_AS
              AND NOT (
                          PayGlobalEmployeeRefs IS NULL
                          AND DayforceEmployeeRefs IS NULL
                      );
    END;

    IF @ExcludeVacantPayGlobalPositionAndNoMatchingDayforceRecord = 1
    BEGIN

        -- Remove empty PayGlobal positions that don't match to dayforce.
        DELETE FROM #FilteredWAPS
        WHERE PayGlobalEmployeeRefs IS NULL
              AND NOT EXISTS
                      (
                          SELECT 1
                          FROM dbo.DataSynchPositions dp
                          WHERE LEN(dp.PositionNumber) >= 4
                                AND LEFT(dp.PositionNumber, LEN(dp.PositionNumber) - 4) = WAPCode COLLATE Latin1_General_CI_AS
                      )
              AND
              (
                  XWAPENDDATE IS NULL
                  OR XWAPENDDATE > GETDATE()
              );
    END;

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM #FilteredWAPS;

    -- Return paginated results
    SELECT *,
           dbo.fn_GetActiveEmployeesByWAPCode(WAPCode, DEFAULT) AS Employees,
           IIF(
               PayGlobalEmployeeRefs IS NULL
               AND DayforceEmployeeRefs IS NULL,
               0,
               IIF(ISNULL(PayGlobalEmployeeRefs, '') = ISNULL(DayforceEmployeeRefs, '')COLLATE Latin1_General_CI_AS,
                   1,
                   0)) AS MatchesDayforce
    FROM #FilteredWAPS
    ORDER BY Description OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #FilteredWAPS;

END;
GO


