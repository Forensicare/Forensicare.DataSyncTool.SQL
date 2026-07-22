CREATE OR ALTER PROCEDURE dbo.spSyncData_GetOrphanedPayGlobalEmployees
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Set output parameter from temp table
    SELECT @RecordCount = COUNT(*)
    FROM dbo.Syn_Employee
    WHERE '1' + EmployeeCode NOT IN
          (
              SELECT DISTINCT EmployeeReferenceCode FROM dbo.DataSynchEmployees
          );

    SELECT EmployeeCode,
           LastName,
           FirstNames,
           Gender,
           BirthDate,
           PreferredName,
           PreviousName,
           Title,
           MaritalStatus,
           NationalityCode,
           Address1,
           Address2,
           Address3,
           Address4,
           PostCode,
           State,
           CountryCode,
           HomePhone,
           WorkPhone,
           MobilePhone,
           Fax,
           Email,
           WorkEmail,
           PositionCode,
           WorkAreaCode,
           LocationCode,
           DepartmentCode,
           CostCentreCode
    FROM dbo.Syn_Employee
    WHERE '1' + EmployeeCode NOT IN
          (
              SELECT DISTINCT EmployeeReferenceCode FROM dbo.DataSynchEmployees
          )
    ORDER BY EmployeeCode OFFSET (@Page - 1) * @RecordsPerPage ROWS FETCH NEXT @RecordsPerPage ROWS ONLY;

END;
GO