-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-20
-- Description:	Get a list of mobiles or Emails that are blank in Dayforce
--
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_GetDataForBulkUpdate_IT @MaxRecords INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@MaxRecords)
           id,
           CreatedAt,
           XrefCode,
           DataType,
           Value
    FROM dbo.BulkUploadData
    WHERE UploadCompletedDate IS NULL
    ORDER BY CreatedAt;


END;
GO


