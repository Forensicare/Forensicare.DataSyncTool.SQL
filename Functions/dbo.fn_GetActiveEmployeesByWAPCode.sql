CREATE OR ALTER FUNCTION dbo.fn_GetActiveEmployeesByWAPCode
(
    @WAPCode AS VARCHAR(100),
    @ShowFTE AS BIT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result VARCHAR(MAX);

    SELECT @Result
        = STRING_AGG(
                        '(' + TRIM(e.EmployeeCode) + ') ' + TRIM(e.FirstNames) + ' ' + TRIM(e.LastName)
                        + CASE
                              WHEN @ShowFTE = 1 THEN
                                  ' [FTE: ' + CAST(a.FTE AS VARCHAR(10)) + ']'
                              ELSE
                                  ''
                          END,
                        ',' + CHAR(13) + CHAR(10)
                    ) WITHIN GROUP(ORDER BY e.LastName,
                                            e.FirstNames)
    FROM Syn_Appointment a
        INNER JOIN Syn_Employee e
            ON e.EmployeeCode = a.EmployeeCode
    WHERE a.WAPCode = @WAPCode
          AND a.Active = 1;

    RETURN @Result;
END;