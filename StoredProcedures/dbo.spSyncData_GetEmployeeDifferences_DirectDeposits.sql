-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-06-17
-- Description:	Get a list of different 
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeDifferences_DirectDeposits
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DFDirectDebit.xrefCode AS DF_XrefCode,
           PGEmp.EmployeeCode AS PG_EmployeeCode,
           DFDirectDebit.AccountNumber AS DF_AccountNumber,
           PGEmp.BankAccount AS PG_BankAccount,
           DFDirectDebit.EffectiveStart AS DF_EffectiveStart,
           PGEmp.DeclarationDate AS PG_DeclarationDate
    INTO #EmployeeDifferences
    FROM dbo.DirectDeposits DFDirectDebit
        INNER JOIN dbo.Syn_Employee PGEmp
            ON DFDirectDebit.xrefCode = '1' + PGEmp.EmployeeCode COLLATE Latin1_General_CI_AS
    WHERE ISNULL(PGEmp.BankAccount, '') <> ISNULL(DFDirectDebit.AccountNumber, '')COLLATE Latin1_General_CI_AS
          OR DFDirectDebit.EffectiveStart <> PGEmp.DeclarationDate;

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM #EmployeeDifferences;

    -- Return paginated results
    SELECT *
    FROM #EmployeeDifferences
    ORDER BY #EmployeeDifferences.DF_XrefCode DESC OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

    DROP TABLE #EmployeeDifferences;

END;
GO


