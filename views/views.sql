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