CREATE OR ALTER FUNCTION dbo.fn_FormatMobileNumber
(
    @MobileNumber VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN

    RETURN REPLACE(REPLACE(REPLACE(ISNULL(@MobileNumber, ''), ' ', ''), '+', ''), '-', '');

END;