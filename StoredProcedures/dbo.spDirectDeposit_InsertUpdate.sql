SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:
-- Create date:
-- Description: Insert or update a Super record matched on xRefCode.
-- Last modified:
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spDirectDeposit_InsertUpdate
(
    @xRefCode VARCHAR(100),
    @EffectiveStart DATE = NULL,
    @AccountNumber VARCHAR(100) = NULL
)
AS
BEGIN

    IF
    (
        SELECT COUNT(*)FROM dbo.DirectDeposits WHERE xRefCode = @xRefCode
    ) = 0
    -- *******************************************************************************************
    -- Insert
    -- *******************************************************************************************
    BEGIN
        INSERT INTO dbo.DirectDeposits
        (
            xRefCode,
            AccountNumber,
            EffectiveStart
        )
        VALUES
        (@xRefCode, @AccountNumber, @EffectiveStart);
    END;
    ELSE
        -- *******************************************************************************************
        -- Update
        -- *******************************************************************************************
        UPDATE dbo.DirectDeposits
        SET AccountNumber = @AccountNumber,
            EffectiveStart = @EffectiveStart,
            ImportedAt = GETDATE()
        WHERE xRefCode = @xRefCode;

END;
GO
