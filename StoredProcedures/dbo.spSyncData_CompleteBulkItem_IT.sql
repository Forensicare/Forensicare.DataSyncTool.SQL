-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-20
-- Description:	Get a list of mobiles or Emails that are blank in Dayforce
--
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[spSyncData_CompleteBulkItem_IT] @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.BulkUploadData
    SET UploadCompletedDate = GETDATE()
    WHERE id = @Id;


END;
GO


