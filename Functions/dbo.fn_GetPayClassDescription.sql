CREATE OR ALTER FUNCTION dbo.fn_GetPayClassDescription
(
    @EmployeeStatusCode VARCHAR(12)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Result VARCHAR(50) = null;

    IF @EmployeeStatusCode = 'CA'
        SET @Result = 'Casual';
    ELSE IF @EmployeeStatusCode = 'FP'
        SET @Result = 'Full Time';
    ELSE IF @EmployeeStatusCode = 'FF'
        SET @Result = 'Fixed Term FT';
    ELSE IF @EmployeeStatusCode = 'PF'
        SET @Result = 'Fixed Term PT';
    ELSE IF @EmployeeStatusCode = 'PP'
        SET @Result = 'Part Time';

    RETURN @Result;
END;