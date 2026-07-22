USE [HCMDW];
GO

/****** Object:  StoredProcedure [dbo].[spDayforce_EmployeeContact_InsertUpdate_IT]    Script Date: 5/06/2026 2:17:26 PM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO



-- =============================================
-- Author:		Marc Deylen
-- Create date: 14/03/2025
-- Description:	
-- Last modified:
--     - 2026-02-27 - J.Hamilton - Populate update timestamp.
--     - 2026-03-11 - J.Hamilton - update using xref/type for matching.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spDayforce_EmployeeContact_InsertUpdate_IT
(
    @PersonContactID INT,
    @xrefCode VARCHAR(100),
    @ContactInformationType_XRefCode VARCHAR(100),
    @Value VARCHAR(200),
    @LastModifiedTimestamp DATETIME
)
AS
BEGIN

    IF
    (
        SELECT COUNT(*)
        FROM dbo.DayforceEmployeeContact
        WHERE xrefCode = @xrefCode
              AND TRIM(ContactInformationType_XRefCode) = TRIM(@ContactInformationType_XRefCode)
    ) = 0
    -- *******************************************************************************************
    -- Insert
    -- *******************************************************************************************
    BEGIN
        INSERT INTO dbo.DayforceEmployeeContact
        (
            [PersonContactID],
            [xrefCode],
            [ContactInformationType_XRefCode],
            [Value],
            [LastModifiedTimestamp],
            [UpdateDate]
        )
        VALUES
        (@PersonContactID, @xrefCode, TRIM(@ContactInformationType_XRefCode), TRIM(@Value), @LastModifiedTimestamp, GETDATE());
    END;
    ELSE
        -- *******************************************************************************************
        -- Update
        -- *******************************************************************************************

        UPDATE dbo.DayforceEmployeeContact
        SET [PersonContactID] = @PersonContactID,
            --, [xrefCode] = @xrefCode
            --, [ContactInformationType_XRefCode] = @ContactInformationType_XRefCode
            [Value] = TRIM(@Value),
            [LastModifiedTimestamp] = @LastModifiedTimestamp,
            [UpdateDate] = GETDATE()
        WHERE xrefCode = @xrefCode
              AND ContactInformationType_XRefCode = @ContactInformationType_XRefCode;

END;
GO


