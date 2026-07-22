CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeTerminationDateDifferences
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM dbo.DataSynchEmployees DFEmp
        INNER JOIN dbo.Syn_Employee PGEmp
            ON DFEmp.EmployeeReferenceCode = '1' + PGEmp.EmployeeCode
    WHERE ISNULL(PGEmp.TerminationDate, '') <> ISNULL(DFEmp.TerminationDate, '');


    SELECT DFEmp.EmployeeDisplayName AS DF_DisplayName,
           DFEmp.EmployeeReferenceCode AS DF_XrefCode,
           DFEmp.TerminationDate AS DF_TerminationDate,
           PGEmp.TerminationDate AS PG_TerminationDate
    FROM dbo.DataSynchEmployees DFEmp
        INNER JOIN dbo.Syn_Employee PGEmp
            ON DFEmp.EmployeeReferenceCode = '1' + PGEmp.EmployeeCode
    WHERE ISNULL(PGEmp.TerminationDate, '') <> ISNULL(DFEmp.TerminationDate, '')
    ORDER BY DFEmp.EmployeeReferenceCode DESC OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;


-- Return paginated results


END;
GO


