-- ----------------------------------------------------------
-- PROCEDURE 1: sp_AddNewAppointment
-- ----------------------------------------------------------
IF OBJECT_ID('sp_AddNewAppointment', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddNewAppointment;
GO

CREATE PROCEDURE sp_AddNewAppointment
    @patientId INT,
    @doctorId INT,
    @hospitalId INT,
    @appointmentDateTime DATETIME2,
    @purpose NVARCHAR(255),
    @status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Safeguard: Block past schedules
    IF @appointmentDateTime < GETDATE()
    BEGIN
        RAISERROR('Validation Error: Cannot schedule an appointment for a past date or time.', 16, 1);
        RETURN;
    END;

    INSERT INTO Appointments (appointmentDateTime, purpose, status, doctorId, patientId, hospitalId)
    VALUES (@appointmentDateTime, @purpose, @status, @doctorId, @patientId, @hospitalId);

    PRINT 'SUCCESS: New appointment successfully booked.';
END;
GO


-- ----------------------------------------------------------
-- PROCEDURE 2: sp_AddNewMedicineToPharmacyStock
-- ----------------------------------------------------------
IF OBJECT_ID('sp_AddNewMedicineToPharmacyStock', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddNewMedicineToPharmacyStock;
GO

CREATE PROCEDURE sp_AddNewMedicineToPharmacyStock
    @medicineName NVARCHAR(100),
    @brand NVARCHAR(100),
    @category NVARCHAR(100),
    @pharmacyId INT,
    @stockQuantity INT,
    @unitPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @medicineId INT;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Lookup medicine ID from Master Registry
        SELECT @medicineId = medicineId FROM Medicines WHERE medicineName = @medicineName;

        -- If it doesn't exist, create catalog item dynamically
        IF @medicineId IS NULL
        BEGIN
            INSERT INTO Medicines (medicineName, brand, category)
            VALUES (@medicineName, @brand, @category);
            
            SET @medicineId = SCOPE_IDENTITY();
        END;

        -- Synchronize with exact table schema: PharmacyInventory
        IF EXISTS (SELECT 1 FROM PharmacyInventory WHERE pharmacyId = @pharmacyId AND medicineId = @medicineId)
        BEGIN
            UPDATE PharmacyInventory
            SET stockQuantity = stockQuantity + @stockQuantity,
                unitPrice = @unitPrice
            WHERE pharmacyId = @pharmacyId AND medicineId = @medicineId;
        END
        ELSE
        BEGIN
            INSERT INTO PharmacyInventory (pharmacyId, medicineId, stockQuantity, unitPrice)
            VALUES (@pharmacyId, @medicineId, @stockQuantity, @unitPrice);
        END;

        COMMIT TRANSACTION;
        PRINT 'SUCCESS: Pharmacy catalog inventory synchronized.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMessage, 16, 1);
    END CATCH;
END;
GO


-- ----------------------------------------------------------
-- PROCEDURE 3: sp_FindNearbyPharmacies (Taking Hospital Name Text)
-- ----------------------------------------------------------
IF OBJECT_ID('sp_FindNearbyPharmacies', 'P') IS NOT NULL
    DROP PROCEDURE sp_FindNearbyPharmacies;
GO

CREATE PROCEDURE sp_FindNearbyPharmacies
    @hospitalName NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @HospitalAddress NVARCHAR(255);
    DECLARE @District NVARCHAR(100);

    -- Find the string address of the hospital name passed in
    SELECT @HospitalAddress = address FROM Hospitals WHERE hospitalName = @hospitalName;

    IF @HospitalAddress IS NULL
    BEGIN
        RAISERROR('Query Error: The requested hospital name could not be located.', 16, 1);
        RETURN;
    END;

    -- Location Parser: Extract city/district from comma formatting
    IF CHARINDEX(',', @HospitalAddress) > 0
    BEGIN
        SET @District = LTRIM(RTRIM(SUBSTRING(@HospitalAddress, CHARINDEX(',', @HospitalAddress) + 1, LEN(@HospitalAddress))));
    END
    ELSE
    BEGIN
        SET @District = @HospitalAddress;
    END;

    -- Match pharmacies by location criteria
    SELECT pharmacyId, pharmacyName, address
    FROM Pharmacies
    WHERE address LIKE '%' + @District + '%';
END;
GO
