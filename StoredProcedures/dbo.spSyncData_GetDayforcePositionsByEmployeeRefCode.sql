-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-
-- Description:	Get dayforce positions by Employee Ref Code
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetDayforcePositionsByEmployeeRefCode @EmployeeReferenceCode INT
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
        INNER JOIN dbo.DataSynchEmployees e
            ON e.PositionNumber = dp.PositionNumber
               AND e.EmployeeDisplayName = dp.OccupantName
    WHERE e.EmployeeReferenceCode = @EmployeeReferenceCode
    ORDER BY dp.PositionNumber,
             dp.OccupantName DESC;

END;
GO


