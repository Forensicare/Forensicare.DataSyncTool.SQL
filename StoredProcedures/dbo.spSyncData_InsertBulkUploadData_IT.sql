-- =============================================
-- Author:		Indo Ty
-- Create date: 2026-05-20
-- Description:	Insert into Bulk Upload Data table if not exist
--
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSyncData_InsertBulkUploadData_IT
    @XrefCode VARCHAR(100),
    @DataType VARCHAR(100),
    @Value VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.BulkUploadData
        WHERE XrefCode = @XrefCode
              AND DataType = @DataType
              AND Value = @Value
    )
    BEGIN

        INSERT INTO dbo.BulkUploadData
        (
            XrefCode,
            DataType,
            Value
        )
        VALUES
        (@XrefCode, @DataType, @Value);
    END;

END;
GO


