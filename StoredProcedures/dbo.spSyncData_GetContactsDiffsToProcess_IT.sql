-- =============================================
-- Author:		Jason Hamilton
-- Create date: 2026-03-06
-- Description:	Get a list of flagged Employee contacts for automated processing.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetContactsDiffsToProcess_IT
	@pMaxRecords INT = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- query filters only those active employees with different info
	SELECT TOP (@pMaxRecords)
		E.xrefCode
		, ee.EmployeeCode
		, E.DisplayName
		, IIF(EE.TerminationDate IS NULL, 'N', 'Y') AS [IsTerminated]
		-- mobile comparison
		, REPLACE(EMobile.Value, ' ', '') AS [DayforceMobile]
		, REPLACE(EE.MobilePhone, ' ', '') AS [PayglobalMobile]
		-- email comparison
		, REPLACE(EEmail.Value, ' ', '') AS [DayforceEmail]
		, REPLACE(EE.WorkEmail, ' ', '') AS [PayglobalEmail]
		, CAST(E.BirthDate AS DATE) AS [DayforceBirthDate]
		,CAST(EE.BirthDate AS DATE) AS [PayglobalBirthDate]
		-- processing flag
		, E.Processing
	FROM dbo.Syn_Employee EE	
	LEFT JOIN dbo.DayforceEmployeeProcessing E ON E.xrefCode = '1' + EE.EmployeeCode COLLATE Latin1_General_CI_AS
	LEFT JOIN dbo.DayforceEmployeeContact EMobile ON EMobile.xrefCode = E.xrefCode AND EMobile.ContactInformationType_XRefCode = 'Mobile'
	LEFT JOIN dbo.DayforceEmployeeContact EEmail ON EEmail.xrefCode = E.xrefCode AND EEmail.ContactInformationType_XRefCode = 'BusinessEmail'
	WHERE E.Processing = 1
	ORDER BY E.UpdateDate
END
GO


