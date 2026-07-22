-- =============================================
-- Author:		Jason Hamilton
-- Create date: 2026-03-03
-- Description:	Get a list of contacts from active employees that
-- contain differences to process.
--
-- Modified:
--   - 2026-03-06 | JH | Added a processing flag for handling via the web app.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetContactsDiffs_IT
	@IncludeTerminated BIT = 0,
	@Page INT = 1,
	@RecordsPerPage INT = 50,
	@RecordCount INT OUTPUT,
	@FirstNames NVARCHAR(100) = NULL,
	@LastName NVARCHAR(100) = NULL,
	@EmployeeCode VARCHAR(12) = NULL,
	@XRefCode VARCHAR(100) = NULL
	

AS
BEGIN
	SET NOCOUNT ON;

	-- Get total matching record count for pagination
	SELECT @RecordCount = COUNT(*)
	FROM dbo.Syn_Employee EE	
	LEFT JOIN dbo.DayforceEmployeeProcessing E ON E.xrefCode = '1' + EE.EmployeeCode COLLATE Latin1_General_CI_AS
	LEFT JOIN dbo.DayforceEmployeeContact EMobile ON EMobile.xrefCode = E.xrefCode AND EMobile.ContactInformationType_XRefCode = 'Mobile'
	LEFT JOIN dbo.DayforceEmployeeContact EEmail ON EEmail.xrefCode = E.xrefCode AND EEmail.ContactInformationType_XRefCode = 'BusinessEmail'
	WHERE ((REPLACE(ISNULL(EMobile.Value, ''), ' ', '') COLLATE Latin1_General_CI_AS <> REPLACE(ISNULL(EE.MobilePhone, ''), ' ', ''))
		OR (REPLACE(ISNULL(EEmail.Value, ''), ' ', '') COLLATE Latin1_General_CI_AS <> REPLACE(ISNULL(EE.WorkEmail, ''), ' ', ''))
		OR CAST(ee.BirthDate AS DATE) <> CAST(E.BirthDate AS DATE))
		AND (@IncludeTerminated = 1 OR EE.TerminationDate IS NULL)
		AND (@FirstNames IS NULL OR EE.FirstNames LIKE '%' + @FirstNames + '%')
		AND (@LastName IS NULL OR EE.LastName LIKE '%' + @LastName + '%')
		AND (@EmployeeCode IS NULL OR EE.EmployeeCode = @EmployeeCode)
		AND (@XRefCode IS NULL OR E.xrefCode = @XRefCode);

	-- Return paginated results
	SELECT E.xrefCode, 
			ee.EmployeeCode,  
			EE.FirstNames + ' ' + EE.LastName AS  DisplayName, 
			IIF(EE.TerminationDate IS NULL, 'N', 'Y') AS [IsTerminated],		-- mobile comparison
			REPLACE(EMobile.Value, ' ', '') AS [DayforceMobile], 
			REPLACE(EE.MobilePhone, ' ', '') AS [PayglobalMobile],				-- email comparison
			REPLACE(EEmail.Value, ' ', '') AS [DayforceEmail], 
			REPLACE(EE.WorkEmail, ' ', '') AS [PayglobalEmail],					-- processing flag
			CAST(ee.BirthDate AS DATE) AS [PayglobalBirthDate],
			CAST(E.BirthDate AS DATE) AS [DayforceBirthDate],
			E.Processing
	FROM dbo.Syn_Employee EE	
	LEFT JOIN dbo.DayforceEmployeeProcessing E ON E.xrefCode = '1' + EE.EmployeeCode COLLATE Latin1_General_CI_AS
	LEFT JOIN dbo.DayforceEmployeeContact EMobile ON EMobile.xrefCode = E.xrefCode AND EMobile.ContactInformationType_XRefCode = 'Mobile'
	LEFT JOIN dbo.DayforceEmployeeContact EEmail ON EEmail.xrefCode = E.xrefCode AND EEmail.ContactInformationType_XRefCode = 'BusinessEmail'
	WHERE ((REPLACE(ISNULL(EMobile.Value, ''), ' ', '') COLLATE Latin1_General_CI_AS <> REPLACE(ISNULL(EE.MobilePhone, ''), ' ', ''))
		OR (REPLACE(ISNULL(EEmail.Value, ''), ' ', '') COLLATE Latin1_General_CI_AS <> REPLACE(ISNULL(EE.WorkEmail, ''), ' ', ''))
		OR CAST(ee.BirthDate AS DATE) <> CAST(E.BirthDate AS DATE))
		AND (@IncludeTerminated = 1 OR EE.TerminationDate IS NULL)
		AND (@FirstNames IS NULL OR EE.FirstNames LIKE '%' + @FirstNames + '%')
		AND (@LastName IS NULL OR EE.LastName LIKE '%' + @LastName + '%')
		AND (@EmployeeCode IS NULL OR EE.EmployeeCode = @EmployeeCode)
		AND (@XRefCode IS NULL OR E.xrefCode = @XRefCode)
	ORDER BY E.xrefCode
	OFFSET (@Page - 1) * @RecordsPerPage ROWS
	FETCH NEXT @RecordsPerPage ROWS ONLY;

END
GO


