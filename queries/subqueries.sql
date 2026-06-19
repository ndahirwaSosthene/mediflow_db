-- 3 STANDALONE SUBQUERIES
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
