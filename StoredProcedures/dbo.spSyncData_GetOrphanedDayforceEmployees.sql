-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-06-15
-- Description:	Get dayforce orphaned employees
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetOrphanedDayforceEmployees
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT,
    @ExcludedTerminatedEmployees BIT = 1,
    @VerifiedEmployees BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.FirstName,
           d.LastName,
           d.BirthDate
    INTO #DuplicateEmployees
    FROM dbo.DayforceEmployeeProcessing d
    GROUP BY d.FirstName,
             d.LastName,
             d.BirthDate
    HAVING COUNT(*) > 1;

    SELECT dse.EmployeeReferenceCode,
           d.FirstName,
           d.MiddleName,
           d.LastName,
           d.BirthDate,
           dse.EmployeeDisplayName,
           dse.PositionNumber,
           dse.PositionName,
           dse.LocationName,
           dse.FTEValue,
           dse.WorkAssignmentEffectiveStart,
           dse.WorkAssignmentEffectiveEnd,
           dse.EmployeeEmployeeId,
           dse.TerminationDate,
           dse.ExcludeFromOrphanedEmployeesReport,
           dse.ImportedAt,
           CAST(CASE
                    WHEN dup.FirstName IS NOT NULL THEN
                        1
                    ELSE
                        0
                END AS BIT) AS HasPotentialDuplicate
    INTO #OrphanedEmployees
    FROM dbo.DataSynchEmployees dse
        INNER JOIN dbo.DayforceEmployeeProcessing d
            ON d.xrefCode = dse.EmployeeReferenceCode
        LEFT JOIN #DuplicateEmployees dup
            ON dup.BirthDate = d.BirthDate
               AND dup.FirstName = d.FirstName
               AND dup.LastName = d.LastName
    WHERE dse.EmployeeReferenceCode NOT IN
          (
              SELECT DISTINCT '1' + EmployeeCode FROM dbo.Syn_Employee e
          )
          AND
          (
              @ExcludedTerminatedEmployees = 0
              OR dse.TerminationDate IS NULL
          )
          AND dse.ExcludeFromOrphanedEmployeesReport = @VerifiedEmployees;

    DROP TABLE #DuplicateEmployees;

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM #OrphanedEmployees;

    -- Return paginated results
    SELECT *
    FROM #OrphanedEmployees
    ORDER BY EmployeeReferenceCode OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #OrphanedEmployees;

END;
GO


