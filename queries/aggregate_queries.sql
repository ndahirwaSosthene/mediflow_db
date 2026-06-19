-- ============================================================
-- AGGREGATE AND ANALYTICAL QUERIES
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