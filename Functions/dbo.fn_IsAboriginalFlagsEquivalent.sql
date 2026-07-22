CREATE OR ALTER FUNCTION dbo.fn_IsAboriginalFlagsEquivalent
(
    @DF_AboriginalCode VARCHAR(50),
    @PG_AboriginalCode VARCHAR(50)
)
RETURNS BIT
AS
BEGIN

    DECLARE @PG VARCHAR(50) = dbo.fn_NullSafeUpper(@PG_AboriginalCode);
    DECLARE @DF VARCHAR(50) = dbo.fn_NullSafeUpper(@DF_AboriginalCode);

    RETURN IIF(
               (
                   @PG = 'B - ATSI'
                   AND @DF IN ( 'ABORIGINAL', 'ABORIGINALANDTORRESSTRAITISLANDER', 'TORRESSTRAITISLANDER' )
               )
               OR
               (
                   @PG = 'A - Non ATSI'
                   AND @DF = 'NOTABORIGINALORTORRESSTRAITISLANDER'
               )
               OR
               (
                   @PG IN ( 'N - No Response', '' )
                   AND @DF IN ( 'NOTSTATED', '' )
               ),
               1,
               0);
END;