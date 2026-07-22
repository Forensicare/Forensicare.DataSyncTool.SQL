SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:
-- Create date:
-- Description: Insert or update a NextOfKin record matched on xRefCode.
-- Last modified:
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spNextOfKin_InsertUpdate
(
    @xRefCode VARCHAR(100),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Relationship VARCHAR(100),
    @Mobile VARCHAR(100) = NULL,
    @IsPrimary BIT
)
AS
BEGIN

    IF
    (
        SELECT COUNT(*)
        FROM dbo.NextOfKin
        WHERE xRefCode = @xRefCode
              AND REPLACE(ISNULL(Mobile, ''), ' ', '') = REPLACE(ISNULL(@Mobile, ''), ' ', '')
    ) = 0
    -- *******************************************************************************************
    -- Insert
    -- *******************************************************************************************
    BEGIN
        INSERT INTO dbo.NextOfKin
        (
            [xRefCode],
            [FirstName],
            [LastName],
            [Relationship],
            [Mobile],
            [IsPrimary]
        )
        VALUES
        (TRIM(@xRefCode), TRIM(@FirstName), TRIM(@LastName), TRIM(@Relationship), REPLACE(@Mobile, ' ', ''), @IsPrimary);

        IF @Mobile IS NOT NULL
        BEGIN
			-- remove the null record if we are inserting an actual mobile.
            DELETE dbo.NextOfKin
            WHERE TRIM(xRefCode) = TRIM(@xRefCode)
                  AND Mobile IS NULL;
        END;
    END;
    ELSE
        -- *******************************************************************************************
        -- Update
        -- *******************************************************************************************

        UPDATE dbo.NextOfKin
        SET [FirstName] = TRIM(@FirstName),
            [LastName] = TRIM(@LastName),
            [Relationship] = TRIM(@Relationship),
            [Mobile] = REPLACE(@Mobile, ' ', ''),
            [IsPrimary] = @IsPrimary,
            ImportedAt = GETDATE()
        WHERE TRIM(xRefCode) = TRIM(@xRefCode)
              AND REPLACE(ISNULL(Mobile, ''), ' ', '') = REPLACE(ISNULL(@Mobile, ''), ' ', '');
END;
GO
