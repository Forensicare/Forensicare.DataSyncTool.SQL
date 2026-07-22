CREATE OR ALTER FUNCTION dbo.fn_GetStateDescription
(
    @StateCode VARCHAR(12)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Result VARCHAR(50) = null;

    IF @StateCode = 'VIC'
        SET @Result = 'Victoria';
    ELSE IF @StateCode = 'NSW'
        SET @Result = 'New South Wales';
    ELSE IF @StateCode = 'QLD'
        SET @Result = 'Queensland';
    ELSE IF @StateCode = 'SA'
        SET @Result = 'South Australia';
    ELSE IF @StateCode = 'WA'
        SET @Result = 'Western Australia';
    ELSE IF @StateCode = 'TAS'
        SET @Result = 'Tasmania';
    ELSE IF @StateCode = 'NT'
        SET @Result = 'Northern Territory';

    RETURN @Result;
END;