CREATE OR ALTER PROCEDURE dbo.spDayforce_Employee_InsertUpdate_IT
(
    @xRefCode VARCHAR(100),
    @BirthDate DATE,
    @EmployeeLatestUpdatedTimestamp DATETIME,
    @DisplayName VARCHAR(200),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Suffix VARCHAR(100),
    @BirthCountry VARCHAR(200) = NULL,
    @RegisteredDisabled BIT,
    @StartDate DATETIME,
    @Title VARCHAR(100) = NULL,
    @PreviousLastName VARCHAR(100) = NULL,
    @CommonName VARCHAR(100) = NULL,
    @Nationality VARCHAR(100) = NULL,
    @Gender VARCHAR(100) = NULL,
    @PreferredLastName VARCHAR(100) = NULL,
    @MiddleName VARCHAR(100) = NULL,
    @TaxFileNumber VARCHAR(25) = NULL,
    @PayClass VARCHAR(50) = NULL,
    @BankAccountNumber VARCHAR(50) = NULL,
    @Address1 VARCHAR(100) = NULL,
    @Address2 VARCHAR(100) = NULL,
    @City VARCHAR(100) = NULL,
    @PostalCode VARCHAR(100) = NULL,
    @Country VARCHAR(100) = NULL,
    @State VARCHAR(100) = NULL,
    @IndigenousStatus VARCHAR(100) = NULL
)
AS
BEGIN
    MERGE dbo.DayforceEmployeeProcessing AS target
    USING
    (
        SELECT TRIM(@xRefCode) AS xrefcode,
               @BirthDate AS BirthDate,
               @EmployeeLatestUpdatedTimestamp AS EmployeeLatestUpdatedTimestamp,
               TRIM(@DisplayName) AS DisplayName,
               TRIM(@FirstName) AS FirstName,
               TRIM(@LastName) AS LastName,
               TRIM(@Suffix) AS Suffix,
               TRIM(@BirthCountry) AS BirthCountry,
               @RegisteredDisabled AS RegisteredDisabled,
               @StartDate AS StartDate,
               TRIM(@Title) AS Title,
               TRIM(@PreviousLastName) AS PreviousLastName,
               TRIM(@CommonName) AS CommonName,
               TRIM(@Nationality) AS Nationality,
               TRIM(@Gender) AS Gender,
               TRIM(@PreferredLastName) AS PreferredLastName,
               TRIM(@MiddleName) AS MiddleName,
               TRIM(@TaxFileNumber) AS TaxFileNumber,
               TRIM(@PayClass) AS PayClass,
               TRIM(@BankAccountNumber) AS BankAccountNumber,
               TRIM(@Address1) AS Address1,
               TRIM(@Address2) AS Address2,
               TRIM(@City) AS City,
               TRIM(@PostalCode) AS PostalCode,
               TRIM(@Country) AS Country,
               TRIM(@State) AS State,
               TRIM(@IndigenousStatus) AS IndigenousStatus
    ) AS source
    ON target.xrefCode = source.xrefcode

    -- *******************************************************************************************
    -- Update
    -- *******************************************************************************************
    WHEN MATCHED THEN
        UPDATE SET BirthDate = source.BirthDate,
                   EmployeeLatestUpdatedTimestamp = source.EmployeeLatestUpdatedTimestamp,
                   DisplayName = source.DisplayName,
                   FirstName = source.FirstName,
                   LastName = source.LastName,
                   Suffix = source.Suffix,
                   BirthCountry = source.BirthCountry,
                   RegisteredDisabled = source.RegisteredDisabled,
                   StartDate = source.StartDate,
                   Title = source.Title,
                   PreviousLastName = source.PreviousLastName,
                   Nationality = source.Nationality,
                   CommonName = source.CommonName,
                   Gender = source.Gender,
                   UpdateDate = GETDATE(),
                   PreferredLastName = source.PreferredLastName,
                   MiddleName = source.MiddleName,
                   TaxFileNumber = source.TaxFileNumber,
                   PayClass = source.PayClass,
                   BankAccountNumber = source.BankAccountNumber,
                   Address1 = source.Address1,
                   Address2 = source.Address2,
                   City = source.City,
                   PostalCode = source.PostalCode,
                   Country = source.Country,
                   State = source.State,
                   IndigenousStatus = source.IndigenousStatus,
                   Processing = 0 -- ensures this flag is reset after an update

    -- *******************************************************************************************
    -- Insert
    -- *******************************************************************************************
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            xrefCode,
            BirthDate,
            EmployeeLatestUpdatedTimestamp,
            DisplayName,
            FirstName,
            LastName,
            Suffix,
            BirthCountry,
            RegisteredDisabled,
            StartDate,
            Title,
            PreviousLastName,
            Nationality,
            CommonName,
            Gender,
            PreferredLastName,
            MiddleName,
            TaxFileNumber,
            PayClass,
            BankAccountNumber,
            Address1,
            Address2,
            City,
            PostalCode,
            Country,
            State,
            IndigenousStatus
        )
        VALUES
        (source.xrefcode, source.BirthDate, source.EmployeeLatestUpdatedTimestamp, source.DisplayName,
         source.FirstName, source.LastName, source.Suffix, source.BirthCountry, source.RegisteredDisabled,
         source.StartDate, source.Title, source.PreviousLastName, source.Nationality, source.CommonName, source.Gender,
         source.PreferredLastName, source.MiddleName, source.TaxFileNumber, source.PayClass, source.BankAccountNumber,
         source.Address1, source.Address2, source.City, source.PostalCode, source.Country, source.State,
         source.IndigenousStatus);
END;
GO


