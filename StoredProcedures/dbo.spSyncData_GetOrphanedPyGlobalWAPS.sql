CREATE OR ALTER PROCEDURE dbo.spSyncData_GetOrphanedPyGlobalWAPS
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT W.WAPID,
           W.WAPCode,
           W.Status,
           W.XWAPENDDATE
    INTO #OrphanedWAPS
    FROM dbo.Syn_WAP W
    WHERE W.Status = 'OPEN'
          AND
          (
              W.XWAPENDDATE IS NULL
              OR W.XWAPENDDATE > GETDATE()
          )
          AND NOT EXISTS
                  (
                      SELECT 1
                      FROM dbo.Syn_Appointment A
                      WHERE A.WAPCode = W.WAPCode
                            AND A.Active = 1
                  )
          AND NOT EXISTS
                  (
                      SELECT 1
                      FROM dbo.DataSynchPositions dp
                      WHERE LEN(dp.PositionNumber) >= 4
                            AND LEFT(dp.PositionNumber, LEN(dp.PositionNumber) - 4) = W.WAPCode COLLATE Latin1_General_CI_AS
                  );

    SELECT @RecordCount = COUNT(*)
    FROM #OrphanedWAPS;

    SELECT WAPID,
           WAPCode,
           Status,
           XWAPENDDATE
    FROM #OrphanedWAPS
    ORDER BY WAPCode OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #OrphanedWAPS;

END;
GO


