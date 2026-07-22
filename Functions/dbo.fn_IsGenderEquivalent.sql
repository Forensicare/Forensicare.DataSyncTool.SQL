CREATE OR ALTER FUNCTION dbo.fn_IsGenderEquivalent
(
    @DF_Gender VARCHAR(50),
    @PG_Gender VARCHAR(50)
)
RETURNS BIT
AS
BEGIN

    DECLARE @DF VARCHAR(50) = dbo.fn_NullSafeUpper(@DF_Gender);
    DECLARE @PG VARCHAR(50) = dbo.fn_NullSafeUpper(@PG_Gender);

    RETURN IIF((@PG = @DF) OR (@PG = 'PREFER NOT TO SAY' AND @DF = 'PREFERNOTTOSAY'), 1, 0);

END;