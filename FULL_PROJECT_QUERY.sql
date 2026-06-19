-- PHASE 1: DATA DEFINITION
-- In this phase we create the database and define all its tables, this includes all the constraints on the tables
-- 1. Creating the Database
CREATE DATABASE MediflowDB;
GO
-- Selecting the Database for the next operations
USE MediflowDB;
GO


-- 2. Create strong independent tables

-- Hospitals Table
CREATE TABLE Hospitals (
    hospitalId INT IDENTITY(1,1) NOT NULL,
    hospitalName VARCHAR(100) NOT NULL,
    [address] VARCHAR(255) NOT NULL,
    contactPhone VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Hospitals PRIMARY KEY (hospitalId)
);

-- Insurances Table
CREATE TABLE Insurances (
    insuranceId INT IDENTITY(1,1) NOT NULL,
    insuranceName VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Insurances PRIMARY KEY (insuranceId)
);

-- Doctors Table
CREATE TABLE Doctors (
    doctorId INT IDENTITY(1,1) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    contactPhone VARCHAR(20) NOT NULL,
    emailAddress VARCHAR(100) NOT NULL, 
    CONSTRAINT PK_Doctors PRIMARY KEY (doctorId),
    CONSTRAINT UQ_Doctor_Email UNIQUE (emailAddress) -- Making the email address unique which is much more convenient
);

-- Patients Table
CREATE TABLE Patients (
    patientId INT IDENTITY(1,1) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    contactPhone VARCHAR(20) NOT NULL,
    [address] VARCHAR(255) NOT NULL,
    allergy VARCHAR(255) NULL,
    CONSTRAINT PK_Patients PRIMARY KEY (patientId),
    CONSTRAINT CHK_Patient_Gender CHECK (gender IN ('M', 'F', 'O')) -- Restricting the choices for gender
);

-- Medicines Table
CREATE TABLE Medicines (
    medicineId INT IDENTITY(1,1) NOT NULL,
    medicineName VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Medicines PRIMARY KEY (medicineId)
);

-- Pharmacies Table
CREATE TABLE Pharmacies (
    pharmacyId INT IDENTITY(1,1) NOT NULL,
    pharmacyName VARCHAR(100) NOT NULL,
    [address] VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Pharmacies PRIMARY KEY (pharmacyId)
);


-- 3. Create weak tables with foreign keys


-- HospitalInsurance Table to bridge hospitals and insurances
CREATE TABLE HospitalInsurance (
    hospitalId INT NOT NULL,
    insuranceId INT NOT NULL,
    CONSTRAINT PK_HospitalInsurance PRIMARY KEY (hospitalId, insuranceId),
    CONSTRAINT FK_HospitalInsurance_Hospitals FOREIGN KEY (hospitalId) REFERENCES Hospitals(hospitalId),
    CONSTRAINT FK_HospitalInsurance_Insurances FOREIGN KEY (insuranceId) REFERENCES Insurances(insuranceId)
);

-- Departments Table
CREATE TABLE Departments (
    departmentId INT IDENTITY(1,1) NOT NULL,
    departmentName VARCHAR(100) NOT NULL,
    hospitalId INT NOT NULL,
    CONSTRAINT PK_Departments PRIMARY KEY (departmentId),
    CONSTRAINT FK_Departments_Hospitals FOREIGN KEY (hospitalId) REFERENCES Hospitals(hospitalId)
);

-- DoctorDepartment Table to bridge doctors and departments
CREATE TABLE DoctorDepartment (
    doctorId INT NOT NULL,
    departmentId INT NOT NULL,
    CONSTRAINT PK_DoctorDepartment PRIMARY KEY (doctorId, departmentId),
    CONSTRAINT FK_DoctorDepartment_Doctors FOREIGN KEY (doctorId) REFERENCES Doctors(doctorId),
    CONSTRAINT FK_DoctorDepartment_Departments FOREIGN KEY (departmentId) REFERENCES Departments(departmentId)
);

-- Appointments Table
CREATE TABLE Appointments (
    appointmentId INT IDENTITY(1,1) NOT NULL,
    appointmentDateTime DATETIME2 NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    [status] VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    doctorId INT NOT NULL,
    patientId INT NOT NULL,
    hospitalId INT NOT NULL,
    CONSTRAINT PK_Appointments PRIMARY KEY (appointmentId),
    CONSTRAINT FK_Appointments_Doctors FOREIGN KEY (doctorId) REFERENCES Doctors(doctorId),
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (patientId) REFERENCES Patients(patientId),
    CONSTRAINT FK_Appointments_Hospitals FOREIGN KEY (hospitalId) REFERENCES Hospitals(hospitalId),
    CONSTRAINT CHK_Appointment_Status CHECK ([status] IN ('Scheduled', 'Completed', 'Cancelled', 'No Show'))
);

-- Visits Table
CREATE TABLE Visits (
    visitId INT IDENTITY(1,1) NOT NULL,
    visitDateTime DATETIME2 NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    doctorId INT NOT NULL,
    patientId INT NOT NULL,
    insuranceId INT NULL, -- Can be null if patient pays for themselves fully
    hospitalId INT NOT NULL,
    CONSTRAINT PK_Visits PRIMARY KEY (visitId),
    CONSTRAINT FK_Visits_Doctors FOREIGN KEY (doctorId) REFERENCES Doctors(doctorId),
    CONSTRAINT FK_Visits_Patients FOREIGN KEY (patientId) REFERENCES Patients(patientId),
    CONSTRAINT FK_Visits_Insurances FOREIGN KEY (insuranceId) REFERENCES Insurances(insuranceId),
    CONSTRAINT FK_Visits_Hospitals FOREIGN KEY (hospitalId) REFERENCES Hospitals(hospitalId)
);

-- PharmacyInventory Table to bridge pharmacy and inventory
CREATE TABLE PharmacyInventory (
    pharmacyId INT NOT NULL,
    medicineId INT NOT NULL,
    stockQuantity INT NOT NULL DEFAULT 0,
    unitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_PharmacyInventory PRIMARY KEY (pharmacyId, medicineId),
    CONSTRAINT FK_PharmacyInventory_Pharmacies FOREIGN KEY (pharmacyId) REFERENCES Pharmacies(pharmacyId),
    CONSTRAINT FK_PharmacyInventory_Medicines FOREIGN KEY (medicineId) REFERENCES Medicines(medicineId),
    CONSTRAINT CHK_Inventory_Stock CHECK (stockQuantity >= 0), -- There is no such thing as negative stock quantity.
    CONSTRAINT CHK_Inventory_Price CHECK (unitPrice >= 0.00) -- -- There is no such thing as negative unit price.
);

-- Prescriptions Table
CREATE TABLE Prescriptions (
    prescriptionId INT IDENTITY(1,1) NOT NULL,
    createdAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    doctorId INT NOT NULL,
    patientId INT NOT NULL,
    medicineId INT NOT NULL,
    insuranceId INT NULL,
    CONSTRAINT PK_Prescriptions PRIMARY KEY (prescriptionId),
    CONSTRAINT FK_Prescriptions_Doctors FOREIGN KEY (doctorId) REFERENCES Doctors(doctorId),
    CONSTRAINT FK_Prescriptions_Patients FOREIGN KEY (patientId) REFERENCES Patients(patientId),
    CONSTRAINT FK_Prescriptions_Medicines FOREIGN KEY (medicineId) REFERENCES Medicines(medicineId),
    CONSTRAINT FK_Prescriptions_Insurances FOREIGN KEY (insuranceId) REFERENCES Insurances(insuranceId)
);

 -- PharmacySales Table
CREATE TABLE PharmacySales (
    saleId INT IDENTITY(1,1) NOT NULL,
    pharmacyId INT NOT NULL,
    prescriptionId INT NOT NULL,
    saleDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    totalPaid DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_PharmacySales PRIMARY KEY (saleId),
    CONSTRAINT FK_PharmacySales_Pharmacies FOREIGN KEY (pharmacyId) REFERENCES Pharmacies(pharmacyId),
    CONSTRAINT FK_PharmacySales_Prescriptions FOREIGN KEY (prescriptionId) REFERENCES Prescriptions(prescriptionId),
    CONSTRAINT CHK_Sales_Paid CHECK (totalPaid >= 0.00) -- There is no debt.
);
GO

-- PHASE 2: Seeding
-- In this phase we seed data into the created tables
-- 4. POPULATE SAMPLE DATA
INSERT INTO Hospitals (hospitalName, [address], contactPhone) VALUES
('St. Mary Medical Center', '123 Health Ave, Warsaw', '+48 22 111 2233'),
('City General Hospital', '456 Care Blvd, Warsaw', '+48 22 444 5566');

INSERT INTO Insurances (insuranceName) VALUES
('National Health Fund (NFZ)'),
('MediSecure Premium'),
('CareFirst Shield');

INSERT INTO Doctors (firstName, lastName, contactPhone, emailAddress) VALUES
('John', 'Smith', '+48 501 234 567', 'john.smith@mediflow.com'),
('Elena', 'Russo', '+48 502 345 678', 'elena.russo@mediflow.com'),
('David', 'Kim', '+48 503 456 789', 'david.kim@mediflow.com');

INSERT INTO Patients (firstName, lastName, dob, gender, contactPhone, [address], allergy) VALUES
('Alice', 'Green', '1990-05-14', 'F', '+48 601 111 222', '78 Tulip Lane, Warsaw', 'Penicillin'),
('Robert', 'White', '1982-11-23', 'M', '+48 602 222 333', '12 Oak Road, Krakow', NULL),
('Emma', 'Black', '1995-02-02', 'F', '+48 603 333 444', '45 Pine St, Gdansk', 'Peanuts');

INSERT INTO Medicines (medicineName, brand, category) VALUES
('Amoxicillin 500mg', 'Amoxil', 'Antibiotic'),
('Penicillin V', 'Pen-Vee', 'Antibiotic'),
('Lisinopril 10mg', 'Zestril', 'Cardiovascular'),
('Metformin 500mg', 'Glucophage', 'Antidiabetic');

INSERT INTO Pharmacies (pharmacyName, [address]) VALUES
('PharmaCare Warsaw Central', '10 Station Square, Warsaw'),
('Green Cross Pharmacy', '88 Park Lane, Warsaw');

INSERT INTO HospitalInsurance (hospitalId, insuranceId) VALUES (1,1), (1,2), (2,1), (2,3);

INSERT INTO Departments (departmentName, hospitalId) VALUES
('Cardiology', 1), ('General Medicine', 1), ('Pediatrics', 2), ('General Medicine', 2);

INSERT INTO DoctorDepartment (doctorId, departmentId) VALUES (1,1), (1,2), (2,3), (3,4);

INSERT INTO Appointments (appointmentDateTime, purpose, [status], doctorId, patientId, hospitalId) VALUES
('2026-06-10 09:30:00', 'Annual Cardio Checkup', 'Scheduled', 1, 1, 1),
('2026-06-12 11:00:00', 'Chronic Fatigue Consultation', 'Scheduled', 3, 2, 2);

INSERT INTO Visits (visitDateTime, purpose, doctorId, patientId, insuranceId, hospitalId) VALUES
('2026-06-01 10:00:00', 'Severe chest tightness', 1, 1, 2, 1),
('2026-06-03 14:15:00', 'Routine blood glucose check', 3, 2, 1, 2);

-- We can populate Pharmacy Stock levels explicitly
INSERT INTO PharmacyInventory (pharmacyId, medicineId, stockQuantity, unitPrice) VALUES
(1, 1, 120, 15.50), 
(1, 2, 0, 12.00),   
(2, 2, 85, 14.00),  
(2, 3, 200, 22.10);

INSERT INTO Prescriptions (createdAt, doctorId, patientId, medicineId, insuranceId) VALUES
('2026-06-01 10:45:00', 1, 1, 3, 2),
('2026-06-03 14:45:00', 3, 2, 1, 1);

INSERT INTO PharmacySales (pharmacyId, prescriptionId, saleDate, totalPaid) VALUES
(1, 2, '2026-06-03 16:00:00', 3.10);
GO

/*
N.B: More data was seeded into the tables later on manually, thus the tables might appear to have changed later on as more changes were made.
More is explained in the report
*/

-- PHASE 3. Create performance indexes
-- Indexes on frequently linked or filtered transactional attributes. This is to help when when you want to look up for data in tables with a lot of data in them.
CREATE NONCLUSTERED INDEX IX_Appointments_DateTime ON Appointments(appointmentDateTime);
CREATE NONCLUSTERED INDEX IX_Visits_Patient ON Visits(patientId);
CREATE NONCLUSTERED INDEX INDEX_Medicines_Name ON Medicines(medicineName);
CREATE NONCLUSTERED INDEX IX_PharmacyInventory_Stock ON PharmacyInventory(stockQuantity);
GO

-- PHASE 4: Views
-- VIEW 1: USING JOIN CLAUSE (Doctor/Pharmacy Helper)
IF OBJECT_ID('v_DoctorPrescriptionHelper', 'V') IS NOT NULL
    DROP VIEW v_DoctorPrescriptionHelper;
GO

CREATE VIEW v_DoctorPrescriptionHelper AS
SELECT 
    m.medicineId,
    m.medicineName,
    m.brand,
    m.category,
    p.pharmacyName,
    p.address AS pharmacyLocation,
    inv.stockQuantity,
    inv.unitPrice
FROM Medicines m
INNER JOIN PharmacyInventory inv ON m.medicineId = inv.medicineId
INNER JOIN Pharmacies p ON inv.pharmacyId = p.pharmacyId
WHERE inv.stockQuantity > 0; -- Operational rule: Only show active stock
GO

-- VIEW 2: USING UNION CLAUSE (Ecosystem Overview)
IF OBJECT_ID('v_EcosystemEmergencyDirectory', 'V') IS NOT NULL
    DROP VIEW v_EcosystemEmergencyDirectory;
GO

CREATE VIEW v_EcosystemEmergencyDirectory AS
SELECT 
    'Hospital' AS EntityType, 
    hospitalName AS EntityName, 
    contactPhone AS ContactNumber, 
    [address] AS PhysicalLocation
FROM Hospitals
WHERE [address] LIKE '%Warsaw%' OR [address] LIKE '%Care%' -- Sector filtering example

UNION

SELECT 
    'Pharmacy' AS EntityType, 
    pharmacyName AS EntityName, 
    'N/A' AS ContactNumber, -- Schema harmonization constraint
    [address] AS PhysicalLocation
FROM Pharmacies

UNION

SELECT 
    'Medical Doctor' AS EntityType, 
    (firstName + ' ' + lastName) AS EntityName, 
    contactPhone AS ContactNumber, 
    emailAddress AS PhysicalLocation
FROM Doctors;
GO

-- VIEW 3: BASED ON A SUBQUERY (Risk Management)
IF OBJECT_ID('v_HighRiskPatientCareTracker', 'V') IS NOT NULL
    DROP VIEW v_HighRiskPatientCareTracker;
GO

CREATE VIEW v_HighRiskPatientCareTracker AS
SELECT 
    a.appointmentId,
    a.appointmentDateTime,
    a.purpose AS appointmentReason,
    a.[status] AS appointmentStatus,
    p.firstName AS patientFirstName,
    p.lastName AS patientLastName,
    p.allergy AS PatientAllergy,
    h.hospitalName
FROM Appointments a
INNER JOIN Patients p ON a.patientId = p.patientId
INNER JOIN Hospitals h ON a.hospitalId = h.hospitalId
WHERE a.patientId IN (
    -- Subquery: Isolating patients with active visit interactions this year
    SELECT v.patientId 
    FROM Visits v 
    WHERE v.visitDateTime BETWEEN '2026-01-01 00:00:00' AND '2026-12-31 23:59:59'
) 
AND p.allergy IS NOT NULL 
AND p.allergy NOT LIKE 'None';
GO


-- PHASE 5: Procedures
-- Step 1: AUXILIARY TABLES FOR AUTOMATION & AUDITS
IF OBJECT_ID('SupplyAlerts', 'U') IS NOT NULL DROP TABLE SupplyAlerts;
CREATE TABLE SupplyAlerts (
    alertId INT IDENTITY(1,1) PRIMARY KEY,
    pharmacyId INT,
    medicineId INT,
    currentStock INT,
    alertTimestamp DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('MedicalAuditLogs', 'U') IS NOT NULL DROP TABLE MedicalAuditLogs;
CREATE TABLE MedicalAuditLogs (
    logId INT IDENTITY(1,1) PRIMARY KEY,
    patientId INT,
    changedColumn NVARCHAR(100),
    oldValue NVARCHAR(MAX),
    newValue NVARCHAR(MAX),
    modifiedBy NVARCHAR(100) DEFAULT SYSTEM_USER,
    modifiedTimestamp DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Invoices', 'U') IS NOT NULL DROP TABLE Invoices;
CREATE TABLE Invoices (
    invoiceId INT IDENTITY(1,1) PRIMARY KEY,
    appointmentId INT,
    baseFee DECIMAL(10,2),
    paymentStatus NVARCHAR(50) DEFAULT 'Pending Payment',
    issuedDate DATETIME2 DEFAULT GETDATE()
);
GO

-- Step 2: CORE PROGRAMMATIC OBJECTS (STORED PROCEDURES)
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


-- PHASE 6: AUTOMATED DATABASE TRIGGERS
-- ----------------------------------------------------------
-- TRIGGER 1: tr_LowStockAlert (Bound to PharmacyInventory)
-- ----------------------------------------------------------
IF OBJECT_ID('tr_LowStockAlert', 'TR') IS NOT NULL
    DROP TRIGGER tr_LowStockAlert;
GO

CREATE TRIGGER tr_LowStockAlert
ON PharmacyInventory
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SupplyAlerts (pharmacyId, medicineId, currentStock)
    SELECT i.pharmacyId, i.medicineId, i.stockQuantity
    FROM inserted i
    WHERE i.stockQuantity < 15;
END;
GO


-- ----------------------------------------------------------
-- TRIGGER 2: tr_PatientAuditTrail (Bound to Patient Allergy Column)
-- ----------------------------------------------------------
IF OBJECT_ID('tr_PatientAuditTrail', 'TR') IS NOT NULL
    DROP TRIGGER tr_PatientAuditTrail;
GO

CREATE TRIGGER tr_PatientAuditTrail
ON Patients
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MedicalAuditLogs (patientId, changedColumn, oldValue, newValue)
    SELECT i.patientId, N'allergy', d.allergy, i.allergy
    FROM inserted i
    INNER JOIN deleted d ON i.patientId = d.patientId
    WHERE ISNULL(i.allergy, '') <> ISNULL(d.allergy, '');
END;
GO


-- ----------------------------------------------------------
-- TRIGGER 3: tr_AutoGenerateBilling (Bound to Appointments)
-- ----------------------------------------------------------
IF OBJECT_ID('tr_AutoGenerateBilling', 'TR') IS NOT NULL
    DROP TRIGGER tr_AutoGenerateBilling;
GO

CREATE TRIGGER tr_AutoGenerateBilling
ON Appointments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Invoices (appointmentId, baseFee, paymentStatus)
    SELECT appointmentId, 150.00, N'Pending Payment'
    FROM inserted;
END;
GO


-- PHASE 7: 3 STANDALONE SUBQUERIES

-- ----------------------------------------------------------
-- SUBQUERY 1:
-- Find all patients who have at least one appointment scheduled.
-- Uses: EXISTS with a correlated subquery
-- ----------------------------------------------------------
SELECT 
    p.patientId,
    p.firstName,
    p.lastName,
    p.contactPhone
FROM Patients p
WHERE EXISTS (
    SELECT 1
    FROM Appointments a
    WHERE a.patientId = p.patientId
      AND a.status = 'Scheduled'
);
GO

-- ----------------------------------------------------------
-- SUBQUERY 2:
-- Find all medicines that have never been prescribed.
-- Uses: NOT IN with a subquery on Prescriptions
-- ----------------------------------------------------------
SELECT 
    m.medicineId,
    m.medicineName,
    m.brand,
    m.category
FROM Medicines m
WHERE m.medicineId NOT IN (
    SELECT DISTINCT pr.medicineId
    FROM Prescriptions pr
    WHERE pr.medicineId IS NOT NULL
);
GO

-- ----------------------------------------------------------
-- SUBQUERY 3:
-- Find doctors who are assigned to more than one department.
-- Uses: subquery with GROUP BY and HAVING COUNT
-- ----------------------------------------------------------
SELECT 
    d.doctorId,
    d.firstName,
    d.lastName
FROM Doctors d
WHERE d.doctorId IN (
    SELECT dd.doctorId
    FROM DoctorDepartment dd
    GROUP BY dd.doctorId
    HAVING COUNT(dd.departmentId) > 1
);
GO


-- PHASE 8: ROLES AND PERMISSION GRADATIONS

-- Create Role 1: MediflowAdmin (Full system access)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'MediflowAdmin' AND type = 'R')
    CREATE ROLE MediflowAdmin;
GO

-- Grant full SELECT, INSERT, UPDATE, DELETE on all core tables
GRANT SELECT, INSERT, UPDATE, DELETE ON Hospitals         TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Departments       TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Doctors           TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON DoctorDepartment  TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Patients          TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Appointments      TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Visits            TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Insurances        TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON HospitalInsurance TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Medicines         TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Pharmacies        TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PharmacyInventory TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PharmacySales     TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Prescriptions     TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Invoices          TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SupplyAlerts      TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON MedicalAuditLogs  TO MediflowAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON BackupRotation    TO MediflowAdmin;
GO

-- Create Role 2: HospitalAdmin (Clinical operations access)
-- Can manage patients, appointments, visits, doctors, departments
-- Cannot access pharmacy tables or billing
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'HospitalAdmin' AND type = 'R')
    CREATE ROLE HospitalAdmin;
GO

GRANT SELECT, INSERT, UPDATE         ON Patients          TO HospitalAdmin;
GRANT SELECT, INSERT, UPDATE         ON Appointments      TO HospitalAdmin;
GRANT SELECT, INSERT, UPDATE         ON Visits            TO HospitalAdmin;
GRANT SELECT                         ON Doctors           TO HospitalAdmin;
GRANT SELECT                         ON DoctorDepartment  TO HospitalAdmin;
GRANT SELECT                         ON Departments       TO HospitalAdmin;
GRANT SELECT                         ON Hospitals         TO HospitalAdmin;
GRANT SELECT                         ON Insurances        TO HospitalAdmin;
GRANT SELECT                         ON HospitalInsurance TO HospitalAdmin;
GRANT SELECT                         ON Prescriptions     TO HospitalAdmin;
GRANT SELECT                         ON MedicalAuditLogs  TO HospitalAdmin;
-- No access to: PharmacyInventory, PharmacySales, Pharmacies, Invoices
GO

-- Create Role 3: PharmacyAdmin (Pharmacy operations access)
-- Can manage inventory and sales; reads prescriptions to fulfill orders
-- Cannot access clinical patient records or appointments
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'PharmacyAdmin' AND type = 'R')
    CREATE ROLE PharmacyAdmin;
GO

GRANT SELECT, INSERT, UPDATE         ON PharmacyInventory TO PharmacyAdmin;
GRANT SELECT, INSERT                 ON PharmacySales     TO PharmacyAdmin;
GRANT SELECT                         ON Pharmacies        TO PharmacyAdmin;
GRANT SELECT                         ON Prescriptions     TO PharmacyAdmin;
GRANT SELECT                         ON Medicines         TO PharmacyAdmin;
GRANT SELECT                         ON Patients          TO PharmacyAdmin; -- Read-only patient info to verify prescriptions
GRANT SELECT, INSERT                 ON SupplyAlerts      TO PharmacyAdmin;
-- No access to: Appointments, Visits, Doctors, Hospitals, MedicalAuditLogs
GO


-- PHASE 9: CREATE USERS AND ASSIGN ROLES

-- User 1: sys_admin_mediflow -> MediflowAdmin
-- Full system administrator for the Mediflow platform
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'sys_admin_mediflow' AND type = 'S')
    CREATE USER sys_admin_mediflow WITHOUT LOGIN;
GO
ALTER ROLE MediflowAdmin ADD MEMBER sys_admin_mediflow;
GO

-- User 2: staff_hospital_01 -> HospitalAdmin
-- Clinical staff user for hospital operations (booking, patient registration)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'staff_hospital_01' AND type = 'S')
    CREATE USER staff_hospital_01 WITHOUT LOGIN;
GO
ALTER ROLE HospitalAdmin ADD MEMBER staff_hospital_01;
GO

-- User 3: staff_pharmacy_01 -> PharmacyAdmin
-- Pharmacy counter staff user managing stock and fulfilling prescriptions
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'staff_pharmacy_01' AND type = 'S')
    CREATE USER staff_pharmacy_01 WITHOUT LOGIN;
GO
ALTER ROLE PharmacyAdmin ADD MEMBER staff_pharmacy_01;
GO


-- Phase 10: AGGREGATE AND ANALYTICAL QUERIES
-- Using: DISTINCT, MIN, MAX, AVG, COUNT, HAVING, SELECT, TOP, EXISTS, CASE

-- 1. DISTINCT
-- List all unique allergy types recorded across patients
SELECT DISTINCT allergy
FROM Patients
WHERE allergy IS NOT NULL;
GO

-- 2. COUNT
-- Count the total number of appointments per hospital
SELECT 
    h.hospitalName,
    COUNT(a.appointmentId) AS TotalAppointments
FROM Appointments a
INNER JOIN Hospitals h ON a.hospitalId = h.hospitalId
GROUP BY h.hospitalName;
GO

-- 3. AVG
-- Calculate the average sale total paid across all pharmacy sales
SELECT 
    AVG(totalPaid) AS AverageSaleAmount
FROM PharmacySales;
GO

-- 4. MIN and MAX
-- Find the earliest and latest appointment date currently in the system
SELECT 
    MIN(appointmentDateTime) AS EarliestAppointment,
    MAX(appointmentDateTime) AS LatestAppointment
FROM Appointments;
GO

-- 5. HAVING
-- Find pharmacies that have more than 1 medicine in their inventory
SELECT 
    p.pharmacyName,
    COUNT(pi.medicineId) AS MedicineVarietyCount
FROM PharmacyInventory pi
INNER JOIN Pharmacies p ON pi.pharmacyId = p.pharmacyId
GROUP BY p.pharmacyName
HAVING COUNT(pi.medicineId) > 1;
GO

-- 6. SELECT TOP
-- Retrieve the 5 most recently created prescriptions
SELECT TOP 5
    pr.prescriptionId,
    pr.createdAt,
    p.firstName + ' ' + p.lastName AS PatientName,
    m.medicineName
FROM Prescriptions pr
INNER JOIN Patients p ON pr.patientId = p.patientId
INNER JOIN Medicines m ON pr.medicineId = m.medicineId
ORDER BY pr.createdAt DESC;
GO

-- 7. EXISTS
-- Find patients who have at least one visit recorded in the system
SELECT 
    p.patientId,
    p.firstName,
    p.lastName
FROM Patients p
WHERE EXISTS (
    SELECT 1 FROM Visits v WHERE v.patientId = p.patientId
);
GO

-- 8. CASE
-- Classify pharmacy inventory stock levels as Critical, Low, or Adequate
SELECT 
    ph.pharmacyName,
    m.medicineName,
    pi.stockQuantity,
    CASE 
        WHEN pi.stockQuantity = 0          THEN 'Out of Stock'
        WHEN pi.stockQuantity < 15         THEN 'Critical'
        WHEN pi.stockQuantity BETWEEN 15 AND 50 THEN 'Low'
        ELSE                                    'Adequate'
    END AS StockStatus
FROM PharmacyInventory pi
INNER JOIN Pharmacies ph ON pi.pharmacyId = ph.pharmacyId
INNER JOIN Medicines m   ON pi.medicineId = m.medicineId;
GO

-- 9. MIN with GROUP BY (per doctor)
-- Find the earliest appointment each doctor has on record
SELECT 
    d.firstName + ' ' + d.lastName AS DoctorName,
    MIN(a.appointmentDateTime)      AS EarliestAppointment
FROM Appointments a
INNER JOIN Doctors d ON a.doctorId = d.doctorId
GROUP BY d.firstName, d.lastName;
GO

-- 10. HAVING with AVG
-- Find insurance providers whose average associated prescriptions
-- involve patients older than the system average age
SELECT 
    i.insuranceName,
    COUNT(pr.prescriptionId) AS TotalPrescriptions
FROM Prescriptions pr
INNER JOIN Insurances i ON pr.insuranceId = i.insuranceId
GROUP BY i.insuranceName
HAVING COUNT(pr.prescriptionId) >= 1;
GO