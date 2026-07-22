-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-06-17
-- Description:	Get a list of different 
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetEmployeeDifferences_Chunk1
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DFEmp.xrefCode AS DF_XrefCode,
           PGEmp.EmployeeCode AS PG_EmployeeCode,
           CAST(DFEmp.BirthDate AS DATE) AS [DF_BirthDate],
           CAST(PGEmp.BirthDate AS DATE) AS [PG_BirthDate],
           DFEmp.BirthCountry AS DF_BirthCountry,
           dbo.fn_GetBirthCountryDescription(DFEmp.BirthCountry) AS DF_BirthCountryDescription,
           PGEmp.XBIRTHCOUNTR AS PG_XBIRTHCOUNTR,
           DFEmp.RegisteredDisabled AS DF_RegisteredDisabled,
           PGEmp.XDISABILITY AS PG_XDisability,
           DFEmp.CommonName AS DF_CommonName,
           DFEmp.PreferredLastName AS DF_PreferredLastName,
           PGEmp.XECSVNAME,
           DFEmp.FirstName AS DF_FirstName,
           DFEmp.MiddleName AS DF_MiddleName,
           PGEmp.FirstNames AS PG_FirstNames,
           DFEmp.LastName AS DF_LastName,
           PGEmp.LastName AS PG_LastName,
           DFEmp.Title AS DF_Title,
           PGEmp.Title AS PG_Title,
           DFEmp.PreviousLastName AS DF_PreviousLastName,
           PGEmp.PreviousName AS PG_PreviousName,
           DFEmp.Address1 AS DF_Address1,
           PGEmp.Address1 AS PG_Address1,
           DFEmp.Address2 AS DF_Address2,
           PGEmp.Address2 AS PG_Address2,
           DFEmp.City AS DF_City,
           PGEmp.Address3 AS PG_Addr3_City,
           DFEmp.PostalCode AS DF_PostalCode,
           PGEmp.PostCode AS PG_PostCode,
           DFEmp.State AS DF_State,
           dbo.fn_GetStateDescription(PGEmp.State) AS PG_State,
           DFEmp.Country AS DF_Country,
           dbo.fn_GetPayGlobalCountryDescription(PGEmp.CountryCode) AS PG_Country,
           DFEmp.TaxFileNumber AS DF_TaxFileNumber,
           PGEmp.TaxNumber AS PG_TaxNumber,
           DFEmp.PayClass AS DF_PayClass,
           dbo.fn_GetPayClassDescription(PGEmp.EmployeeStatusCode) AS PG_EmployeeStatusCode,
           DFEmp.StartDate AS DF_StartDate,
           PGEmp.StartDate AS PG_StartDate,
           dbo.fn_FormatMobileNumber(DFMobile.Value) AS DF_Mobile,
           dbo.fn_FormatMobileNumber(PGEmp.MobilePhone) AS PG_Mobile,
           DFEmp.IndigenousStatus AS DF_IndigenousStatus,
           PGEmp.XABORIGINAL AS PG_XABORIGINAL,
           DFEmp.Gender AS DF_Gender,
           PGEmp.Gender AS PG_Gender,
           DFEmp.UpdateDate
    INTO #EmployeeDifferences
    FROM dbo.DayforceEmployeeProcessing DFEmp
        INNER JOIN dbo.Syn_Employee PGEmp
            ON DFEmp.xrefCode = '1' + PGEmp.EmployeeCode COLLATE Latin1_General_CI_AS
        LEFT JOIN dbo.DayforceEmployeeContact DFMobile
            ON DFMobile.xrefCode = DFEmp.xrefCode
               AND DFMobile.ContactInformationType_XRefCode = 'Mobile'
    WHERE dbo.fn_GetBirthCountryDescription(dbo.fn_NullSafeUpper(DFEmp.BirthCountry)) <> dbo.fn_NullSafeUpper(PGEmp.XBIRTHCOUNTR)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(PGEmp.XECSVNAME) <> (dbo.fn_NullSafeUpper(DFEmp.CommonName) + ' '
                                                       + dbo.fn_NullSafeUpper(DFEmp.PreferredLastName)
                                                      ) COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.FirstName) <> dbo.fn_NullSafeUpper(PGEmp.FirstNames)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.LastName) <> dbo.fn_NullSafeUpper(PGEmp.LastName)COLLATE Latin1_General_CI_AS
          OR
          (
              PGEmp.Title IS NOT NULL
              AND dbo.fn_NullSafeUpper(DFEmp.Title) <> dbo.fn_NullSafeUpper(PGEmp.Title)COLLATE Latin1_General_CI_AS
          )
          OR dbo.fn_NullSafeUpper(DFEmp.PreviousLastName) <> dbo.fn_NullSafeUpper(PGEmp.PreviousName)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.Address1) <> dbo.fn_NullSafeUpper(PGEmp.Address1)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.Address2) <> dbo.fn_NullSafeUpper(PGEmp.Address2)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.City) <> dbo.fn_NullSafeUpper(PGEmp.Address3)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.PostalCode) <> dbo.fn_NullSafeUpper(PGEmp.PostCode)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.State) <> dbo.fn_GetStateDescription(dbo.fn_NullSafeUpper(PGEmp.State))COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.Country) <> dbo.fn_GetPayGlobalCountryDescription(dbo.fn_NullSafeUpper(PGEmp.CountryCode))COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.TaxFileNumber) <> dbo.fn_NullSafeUpper(PGEmp.TaxNumber)COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.PayClass) <> dbo.fn_GetPayClassDescription(dbo.fn_NullSafeUpper(PGEmp.EmployeeStatusCode))COLLATE Latin1_General_CI_AS
          OR dbo.fn_NullSafeUpper(DFEmp.StartDate) <> dbo.fn_NullSafeUpper(PGEmp.StartDate)
          OR dbo.fn_FormatMobileNumber(DFMobile.Value) <> dbo.fn_FormatMobileNumber(PGEmp.MobilePhone)
          OR dbo.fn_IsAboriginalFlagsEquivalent(DFEmp.IndigenousStatus, PGEmp.XABORIGINAL) = 0
          OR dbo.fn_IsGenderEquivalent(DFEmp.Gender, PGEmp.Gender) = 0;

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


