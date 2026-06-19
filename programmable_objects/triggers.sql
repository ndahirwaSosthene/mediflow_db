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

-- We also create tables to hold these results from the triggers.
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
