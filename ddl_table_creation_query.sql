CREATE DATABASE MediflowDB;
GO
USE MediflowDB;
GO

-- 1. Create strong independent tables

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


-- 2. Create weak tables with foreign keys


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