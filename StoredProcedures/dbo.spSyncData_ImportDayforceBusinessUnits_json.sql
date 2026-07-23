CREATE OR ALTER PROCEDURE dbo.spSyncData_ImportDayforceBusinessUnits_json @JsonContent NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.DataSynchBusinessUnits;

    INSERT INTO dbo.DataSynchBusinessUnits
    (
        BusinessUnitLedgerCode,
        BusinessUnitName,
        BusinessUnitReferenceCode,
        BusinessUnitActivationDate,
        BusinessUnitDeActivationDate,
        ImportedAt
    )
    SELECT NULLIF(TRIM(BusinessUnitLedgerCode), ''),
           NULLIF(TRIM(BusinessUnitName), ''),
           NULLIF(TRIM(BusinessUnitReferenceCode), ''),
           -- Dates arrive as ISO 8601 (2024-11-11T00:00:00); strip the time part before casting
           CASE
               WHEN NULLIF(TRIM(BusinessUnitActivationDate), '') IS NULL
                    OR LOWER(TRIM(BusinessUnitActivationDate)) = 'null' THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(BusinessUnitActivationDate), 10) AS DATE)
           END,
           CASE
               WHEN NULLIF(TRIM(BusinessUnitDeActivationDate), '') IS NULL
                    OR LOWER(TRIM(BusinessUnitDeActivationDate)) = 'null' THEN
                   NULL
               ELSE
                   CAST(LEFT(TRIM(BusinessUnitDeActivationDate), 10) AS DATE)
           END,
           GETDATE()
    FROM OPENJSON(@JsonContent)
         WITH
         (
             BusinessUnitLedgerCode VARCHAR(100) '$."Business unit ledger code"',
             BusinessUnitName VARCHAR(200) '$."Business unit name"',
             BusinessUnitReferenceCode VARCHAR(400) '$."Business unit reference code"',
             BusinessUnitActivationDate VARCHAR(50) '$."Business unit activation date"',
             BusinessUnitDeActivationDate VARCHAR(50) '$."Business unit deactivation date"'
         )
    WHERE NULLIF(TRIM(BusinessUnitReferenceCode), '') IS NOT NULL;

END;
