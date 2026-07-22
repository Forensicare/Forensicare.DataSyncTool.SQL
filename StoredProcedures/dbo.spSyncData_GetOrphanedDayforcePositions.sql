-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-
-- Description:	Get dayforce orphaned positions
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetOrphanedDayforcePositions
    @ShowOccupiedPositionsOnly BIT = NULL,
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT df.PositionNumber,
           df.PositionName,
           df.OccupantName,
           df.FTE,
           df.LedgerCode,
           df.PositionDetailEffectiveStart,
           df.PositionDetailEffectiveEnd,
           df.PositionStatus,
           df.PositionStatusEffectiveStart,
           df.PositionStatusEffectiveEnd,
           df.SupportsInterimOccupancy,
           df.PositionReferenceCode
    INTO #OrphanedPositions
    FROM dbo.DataSynchPositions df
    WHERE LEN(df.PositionNumber) >= 4
          AND LEFT(df.PositionNumber, LEN(df.PositionNumber) - 4)COLLATE Latin1_General_CI_AS NOT IN
              (
                  SELECT DISTINCT WAPCode FROM dbo.Syn_WAP
              )
          AND
          (
              @ShowOccupiedPositionsOnly IS NULL
              OR @ShowOccupiedPositionsOnly = 0
              OR
              (
                  @ShowOccupiedPositionsOnly = 1
                  AND ISNULL(df.OccupantName, '') <> ''
              )
          );

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM #OrphanedPositions;

    -- Return paginated results
    SELECT *
    FROM #OrphanedPositions
    ORDER BY PositionNumber OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #OrphanedPositions;

END;
GO


