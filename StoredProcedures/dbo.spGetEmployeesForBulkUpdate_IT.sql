-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-20
-- Description:	Get a list of mobiles or Emails that are blank in Dayforce
--
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[spGetEmployeesForBulkUpdate_IT]
    @IncludeTerminated BIT = 0,
    @Page INT = 1,
    @RecordsPerPage INT = 50,
    @DataType VARCHAR(50),
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @localDataType VARCHAR(50) = LOWER(@DataType);

	IF @localDataType NOT IN ('mobile', 'email')
	BEGIN
		RAISERROR('Invalid @DataType. Must be ''mobile'' or ''email''.', 16, 1);
		RETURN;
	END

SELECT E.xrefCode,
       EE.EmployeeCode,
       CONCAT(EE.FirstNames, ' ', EE.LastName) AS DisplayName,
       IIF(EE.TerminationDate IS NULL, 'N', 'Y') AS IsTerminated,
       CASE
           WHEN @localDataType = 'mobile' THEN
               REPLACE(EE.MobilePhone, ' ', '')
           ELSE
               ''
       END AS PayglobalMobile,
       CASE
           WHEN @localDataType = 'mobile' THEN
               REPLACE(DayforceMobile.[Value], ' ', '')
           ELSE
               ''
       END AS DayforceMobile,
       CASE
           WHEN @localDataType = 'email' THEN
               REPLACE(EE.WorkEmail, ' ', '')
           ELSE
               ''
       END AS PayglobalEmail,
       CASE
           WHEN @localDataType = 'email' THEN
               REPLACE(DayforceEmail.[Value], ' ', '')
           ELSE
               ''
       END AS DayforceEmail,
       CASE
           WHEN b.XrefCode IS NULL THEN
               0
           ELSE
               1
       END AS QueuedForUpdate

--E.Processing
INTO #FilteredEmployees
	FROM dbo.Syn_Employee EE
		LEFT JOIN dbo.DayforceEmployeeProcessing E
			ON E.xrefCode = '1' + EE.EmployeeCode COLLATE Latin1_General_CI_AS
		LEFT JOIN dbo.DayforceEmployeeContact DayforceMobile
			ON DayforceMobile.xrefCode = E.xrefCode
			   AND DayforceMobile.ContactInformationType_XRefCode = 'Mobile'
		LEFT JOIN dbo.DayforceEmployeeContact DayforceEmail
			ON DayforceEmail.xrefCode = E.xrefCode
			   AND DayforceEmail.ContactInformationType_XRefCode = 'BusinessEmail'
		LEFT JOIN dbo.BulkUploadData b
			ON b.xrefCode = E.xrefCode
			   AND b.DataType = @localDataType
	WHERE (
			  (@localDataType = 'mobile' AND REPLACE(ISNULL(DayforceMobile.[Value], ''), ' ', '') = '' AND REPLACE(ISNULL(EE.MobilePhone, ''), ' ', '') <> '')
			  OR (@localDataType = 'email'  AND REPLACE(ISNULL(DayforceEmail.[Value], ''), ' ', '') = '' AND REPLACE(ISNULL(EE.WorkEmail, ''), ' ', '') <> '')
		  )
		  AND (@IncludeTerminated = 1 OR EE.TerminationDate IS NULL)
		  AND E.xrefCode IS NOT NULL;
		  
	-- Set output parameter from temp table
	SELECT @RecordCount = COUNT(*) FROM #FilteredEmployees;

	-- Return paginated results
	SELECT *
	FROM #FilteredEmployees
	ORDER BY xrefCode
	OFFSET (@Page - 1) * @RecordsPerPage ROWS
	FETCH NEXT @RecordsPerPage ROWS ONLY;

	DROP TABLE #FilteredEmployees;




END;
GO


