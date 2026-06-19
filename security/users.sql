-- CREATE USERS AND ASSIGN ROLES

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