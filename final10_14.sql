-- ============================================================
-- STEP 10: 3 STANDALONE SUBQUERIES
-- ============================================================

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


-- ============================================================
-- STEP 12: ROLES AND PERMISSION GRADATIONS
-- ============================================================

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


-- ============================================================
-- STEP 13: CREATE USERS AND ASSIGN ROLES
-- ============================================================

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


-- ============================================================
-- STEP 14: AGGREGATE AND ANALYTICAL QUERIES
-- Using: DISTINCT, MIN, MAX, AVG, COUNT, HAVING,
--        SELECT TOP, EXISTS, CASE
-- ============================================================

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