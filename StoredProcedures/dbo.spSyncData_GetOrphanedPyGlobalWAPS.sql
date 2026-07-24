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
           W.Description,
           W.CostCentreCode,
           W.BudgetFTE,
           W.ParentCode,
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

    WITH BusinessUnits
    AS (SELECT *,
               ROW_NUMBER() OVER (PARTITION BY BusinessUnitLedgerCode ORDER BY BusinessUnitName DESC) AS rn
        FROM dbo.DataSynchBusinessUnits),
         LatestPositions
    AS (SELECT *,
               ROW_NUMBER() OVER (PARTITION BY PositionNumber
                                  ORDER BY PositionStatusEffectiveStart DESC
                                 ) AS rn
        FROM dbo.DataSynchPositions)
    SELECT W.WAPID,
           W.WAPCode,
           W.Status,
           W.Description,
           W.CostCentreCode,
           W.BudgetFTE,
           P.JobAssignmentReferenceCode,
           b.BusinessUnitReferenceCode,
           P.LocationReferenceCode,
           P.PositionReferenceCode AS ParentCode,
           W.XWAPENDDATE
    FROM #OrphanedWAPS W
        LEFT JOIN LatestPositions P
            ON P.PositionNumber LIKE W.ParentCode + '%'
               AND P.rn = 1
               AND TRIM(P.PositionNumber) NOT LIKE '% %'
        LEFT JOIN BusinessUnits b
            ON W.CostCentreCode = b.BusinessUnitLedgerCode
               AND b.rn = 1
    ORDER BY W.WAPCode OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #OrphanedWAPS;

END;
GO


