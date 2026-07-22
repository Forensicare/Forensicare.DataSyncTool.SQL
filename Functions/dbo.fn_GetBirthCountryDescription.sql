CREATE OR ALTER FUNCTION dbo.fn_GetBirthCountryDescription
(
    @BirthCountryCode VARCHAR(12)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Result VARCHAR(50) = NULL;

    SET @Result = CASE @BirthCountryCode
                      WHEN 'AUS' THEN
                          'Australia'
                      WHEN 'BLR' THEN
                          'Belarus'
                      WHEN 'BRB' THEN
                          'Barbados'
                      WHEN 'BTN' THEN
                          'Bhutan'
                      WHEN 'CAN' THEN
                          'Canada'
                      WHEN 'CHN' THEN
                          'China'
                      WHEN 'CZE' THEN
                          'Czech Republic'
                      WHEN 'EGY' THEN
                          'Egypt'
                      WHEN 'ETH' THEN
                          'Ethiopia'
                      WHEN 'FIN' THEN
                          'Finland'
                      WHEN 'FJI' THEN
                          'Fiji Island'
                      WHEN 'GBR' THEN
                          'United Kingdom'
                      WHEN 'GHA' THEN
                          'Ghana'
                      WHEN 'HKG' THEN
                          'Hong Kong'
                      WHEN 'IDN' THEN
                          'Indonesia'
                      WHEN 'IND' THEN
                          'India'
                      WHEN 'IRL' THEN
                          'Ireland'
                      WHEN 'ITA' THEN
                          'Italy'
                      WHEN 'JPN' THEN
                          'Japan'
                      WHEN 'LBN' THEN
                          'Lebanon'
                      WHEN 'LKA' THEN
                          'Sri Lanka'
                      WHEN 'MNE' THEN
                          'Montenegro'
                      WHEN 'MUS' THEN
                          'Mauritius'
                      WHEN 'MYS' THEN
                          'Malaysia'
                      WHEN 'NGA' THEN
                          'Nigeria'
                      WHEN 'NLD' THEN
                          'Netherlands'
                      WHEN 'NPL' THEN
                          'Nepal'
                      WHEN 'NZL' THEN
                          'New Zealand'
                      WHEN 'PAK' THEN
                          'Pakistan'
                      WHEN 'PHL' THEN
                          'Philippines'
                      WHEN 'PNG' THEN
                          'Papua New Guinea'
                      WHEN 'SGP' THEN
                          'Singapore'
                      WHEN 'SOM' THEN
                          'Somalia'
                      WHEN 'SRB' THEN
                          'Serbia'
                      WHEN 'THA' THEN
                          'Thailand'
                      WHEN 'TWN' THEN
                          'Taiwan'
                      WHEN 'UGA' THEN
                          'Uganda'
                      WHEN 'VNM' THEN
                          'Vietnam'
                      WHEN 'ZMB' THEN
                          'Zambia'
                      WHEN 'ZWE' THEN
                          'Zimbabwe'
                  END;

    RETURN @Result;
END;