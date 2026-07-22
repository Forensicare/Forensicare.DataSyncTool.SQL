SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Description: Insert or update a Superannuation
-- record matched on xRefCode.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.spSuperannuation_InsertUpdate
(
    @xRefCode VARCHAR(100),
    @EffectiveStart DATE,
    @EffectiveEnd DATE = NULL,
    @MembershipNumber VARCHAR(100) = NULL,
    @SuperannuationContributionCalcValue DECIMAL(10,2) = NULL,
    @IsActive BIT = NULL,
    @SuperannuationContributionType VARCHAR(100) = NULL,
    @SuperannuationType VARCHAR(100) = NULL,
    @SuperannuationContributionCalculationType VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Superannuation
        WHERE xRefCode = @xRefCode
    )
    BEGIN
        -- Insert
        INSERT INTO dbo.Superannuation
        (
            xRefCode,
            EffectiveStart,
            EffectiveEnd,
            MembershipNumber,
            SuperannuationContributionCalcValue,
            IsActive,
            SuperannuationContributionType,
            SuperannuationType,
            SuperannuationContributionCalculationType
        )
        VALUES
        (
            @xRefCode,
            @EffectiveStart,
            @EffectiveEnd,
            @MembershipNumber,
            @SuperannuationContributionCalcValue,
            @IsActive,
            @SuperannuationContributionType,
            @SuperannuationType,
            @SuperannuationContributionCalculationType
        );
    END
    ELSE
    BEGIN
        -- Update
        UPDATE dbo.Superannuation
        SET EffectiveStart = @EffectiveStart,
            EffectiveEnd = @EffectiveEnd,
            MembershipNumber = @MembershipNumber,
            SuperannuationContributionCalcValue = @SuperannuationContributionCalcValue,
            IsActive = @IsActive,
            SuperannuationContributionType = @SuperannuationContributionType,
            SuperannuationType = @SuperannuationType,
            SuperannuationContributionCalculationType = @SuperannuationContributionCalculationType,
            ImportedAt = GETDATE()
        WHERE xRefCode = @xRefCode;
    END
END;
GO