-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-29
-- Description:	Get details of the Employee and positions from both Payglobal and Dayforce.
--
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeDetails
    @EmployeeCode VARCHAR(20) = NULL,
    @FirstNames VARCHAR(100) = NULL,
    @LastName VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeeCode IS NULL
       AND @FirstNames IS NULL
       AND @LastName IS NULL
    BEGIN
        RAISERROR('At least one search filter must be provided: EmployeeCode, FirstNames, or LastName.', 16, 1);
        RETURN;
    END;

    SELECT w.WAPID,
           w.WAPCode,
           w.Description,
           w.BudgetFTE,
           w.CostCentreCode,
           w.XWAPENDDATE,
           w.ParentCode,
           w.Status,
           w.PositionCode,
           wa.Description AS WorkAreaDescription,
           dbo.fn_GetActiveEmployeesByWAPCode(w.WAPCode,1) AS Employees
    FROM dbo.Syn_WAP w
        INNER JOIN dbo.Syn_Appointment a
            ON w.WAPCode = a.WAPCode
        INNER JOIN dbo.Syn_Employee e
            ON e.EmployeeCode = a.EmployeeCode
        LEFT JOIN dbo.Syn_WorkArea wa
            ON w.WorkAreaCode = wa.WorkAreaCode
    WHERE (
              @EmployeeCode IS NULL
              OR a.EmployeeCode = @EmployeeCode
          )
          AND
          (
              @FirstNames IS NULL
              OR e.FirstNames LIKE @FirstNames + '%'
          )
          AND
          (
              @LastName IS NULL
              OR e.LastName LIKE @LastName + '%'
          )
          AND a.Active = 1;


END;
GO


