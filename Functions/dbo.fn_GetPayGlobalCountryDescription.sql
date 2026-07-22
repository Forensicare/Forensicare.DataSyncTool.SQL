CREATE OR ALTER FUNCTION dbo.fn_GetPayGlobalCountryDescription
(
    @CountryCode VARCHAR(12)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Result VARCHAR(50) = NULL;

    SELECT @Result = Description
    FROM dbo.syn_Country
    WHERE CountryCode = @CountryCode;

    RETURN @Result;
END;



