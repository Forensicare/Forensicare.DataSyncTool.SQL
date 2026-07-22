-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-
-- Description:	Get dayforce positions
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetDayforcePositions @PayGlabalWapCode VARCHAR(200)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT DISTINCT
           dp.PositionNumber,
           dp.PositionName,
           dp.OccupantName,
           dp.FTE AS PositionFTE,
		   e.FTEValue AS EmployeeFTE,
           dp.LedgerCode,
           dp.PositionDetailEffectiveStart,
           dp.PositionDetailEffectiveEnd,
           dp.PositionStatus,
           dp.PositionStatusEffectiveStart,
           dp.PositionStatusEffectiveEnd,
           dp.SupportsInterimOccupancy,
           dp.PositionReferenceCode,
           e.EmployeeReferenceCode
    FROM dbo.DataSynchPositions dp
        LEFT JOIN dbo.DataSynchEmployees e
            ON e.PositionNumber = dp.PositionNumber
               AND e.EmployeeDisplayName = dp.OccupantName
    WHERE LEN(dp.PositionNumber) >= 4
          AND LEFT(dp.PositionNumber, LEN(dp.PositionNumber) - 4) = @PayGlabalWapCode
    ORDER BY dp.PositionNumber,
             dp.OccupantName DESC;

END;
GO


