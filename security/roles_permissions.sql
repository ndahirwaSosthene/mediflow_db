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