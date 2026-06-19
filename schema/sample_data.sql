-- 1. INSURANCES
INSERT INTO Insurances (insuranceName) VALUES
('National Health Fund (NFZ)'),
('MediSecure Premium'),
('CareFirst Shield');
GO


-- 2. HOSPITALS
INSERT INTO Hospitals (hospitalName, [address], contactPhone) VALUES
('Okopowa General Hospital',           '45 Okopowa, Warsaw',              '+48 22 345 6781'),
('Torunska Medical Center',            '78 Torunska, Warsaw',             '+48 22 345 6782'),
('New Life Hospital',                  '123 Ostrobramska, Warsaw',        '+48 22 345 6719'),
('Dr. Warszawa Clinic',                '145 Ostrobramska, Warsaw',        '+48 22 345 6780'),
('Wolska Regional Hospital',           '112 Wolska, Warsaw',              '+48 22 345 6783'),
('Pulawska Health Clinic',             '205 Pulawska, Warsaw',            '+48 22 345 6784'),
('Marszalkowska Medical Institute',    '89 Marszalkowska, Warsaw',        '+48 22 345 6785'),
('Grochowska Community Hospital',      '156 Grochowska, Warsaw',          '+48 22 345 6786'),
('Targowa Specialist Hospital',        '67 Targowa, Warsaw',              '+48 22 345 6787'),
('Zwirki i Wigury Medical Center',     '34 Zwirki i Wigury, Warsaw',      '+48 22 345 6788'),
('Modlinska Healthcare Facility',      '221 Modlinska, Warsaw',           '+48 22 345 6789'),
('Aleja Solidarnosci Hospital',        '310 Aleja Solidarnosci, Warsaw',  '+48 22 345 6790');
GO


-- 3. PHARMACIES
INSERT INTO Pharmacies (pharmacyName, [address]) VALUES
('PharmaCare Warsaw Central', '10 Station Square, Warsaw'),
('Green Cross Pharmacy',      '88 Park Lane, Warsaw');
GO

-- 4. MEDICINES
INSERT INTO Medicines (medicineName, brand, category) VALUES
('Amoxicillin 500mg', 'Amoxil',     'Antibiotic'),
('Penicillin V',      'Pen-Vee',    'Antibiotic'),
('Lisinopril 10mg',   'Zestril',    'Cardiovascular'),
('Metformin 500mg',   'Glucophage', 'Antidiabetic');
GO


-- 5. DOCTORS
INSERT INTO Doctors (firstName, lastName, contactPhone, emailAddress) VALUES
('John',        'Smith',        '+48 501 234 567', 'john.smith@mediflow.com'),
('Elena',       'Russo',        '+48 502 345 678', 'elena.russo@mediflow.com'),
('David',       'Kim',          '+48 503 456 789', 'david.kim@mediflow.com'),
('Anna',        'Kowalska',     '+48 501 123 456', 'anna.kowalska@mediflow.com'),
('Jan',         'Nowak',        '+48 602 345 678', 'jan.nowak@mediflow.com'),
('Maria',       'Wisniewska',   '+48 503 567 890', 'maria.wisniewska@mediflow.com'),
('Piotr',       'Wojcik',       '+48 723 456 789', 'piotr.wojcik@mediflow.com'),
('Katarzyna',   'Kaminska',     '+48 691 234 567', 'katarzyna.kaminska@mediflow.com'),
('Tomasz',      'Lewandowski',  '+48 662 456 789', 'tomasz.lewandowski@mediflow.com'),
('Aleksandra',  'Zielinska',    '+48 505 678 901', 'aleksandra.zielinska@mediflow.com'),
('Jakub',       'Szymanski',    '+48 784 123 456', 'jakub.szymanski@mediflow.com'),
('Magdalena',   'Wozniak',      '+48 607 890 123', 'magdalena.wozniak@mediflow.com'),
('Michal',      'Kozlowski',    '+48 510 345 678', 'michal.kozlowski@mediflow.com'),
('Agnieszka',   'Jankowska',    '+48 608 901 234', 'agnieszka.jankowska@mediflow.com'),
('Mateusz',     'Mazur',        '+48 792 345 678', 'mateusz.mazur@mediflow.com'),
('Zuzanna',     'Krawczyk',     '+48 502 111 222', 'zuzanna.krawczyk@mediflow.com'),
('Filip',       'Piotrowski',   '+48 661 222 333', 'filip.piotrowski@mediflow.com'),
('Julia',       'Grabowska',    '+48 535 333 444', 'julia.grabowska@mediflow.com');
GO


-- 6. PATIENTS
INSERT INTO Patients (firstName, lastName, dob, gender, contactPhone, [address], allergy, insuranceId) VALUES
('Alice',  'Green', '1990-05-14', 'F', '+48 601 111 222', '78 Tulip Lane, Warsaw',  'Penicillin', 2),
('Robert', 'White', '1982-11-23', 'M', '+48 602 222 333', '12 Oak Road, Krakow',    NULL,         1),
('Emma',   'Black', '1995-02-02', 'F', '+48 603 333 444', '45 Pine St, Gdansk',     'Peanuts',    3);
GO


-- 7. HOSPITAL — INSURANCE LINKS (depends on Hospitals, Insurances)
INSERT INTO HospitalInsurance (hospitalId, insuranceId) VALUES
(1, 1), (1, 2),
(2, 1), (2, 3),
(3, 1), (3, 2), (3, 3),
(4, 1), (4, 2), (4, 3),
(5, 1), (5, 2), (5, 3),
(6, 1), (6, 2), (6, 3),
(7, 1), (7, 2), (7, 3),
(8, 1), (8, 2), (8, 3),
(9, 1), (9, 2), (9, 3),
(10,1), (10,2), (10,3),
(11,1), (11,2), (11,3),
(12,1), (12,2), (12,3);
GO


-- 8. DEPARTMENTS
INSERT INTO Departments (departmentName, hospitalId) VALUES
('Cardiology',       1),
('General Medicine', 1),
('Pediatrics',       2),
('General Medicine', 2),
('Neurology',        1),
('Orthopedics',      2),
('Oncology',         3),
('Cardiology',       4),
('Pediatrics',       5);
GO


-- 9. DOCTOR — DEPARTMENT LINKS (depends on Doctors, Departments)
--    Uses dynamic lookup to avoid hardcoded identity IDs
INSERT INTO DoctorDepartment (doctorId, departmentId)
SELECT src.doctorId, dep.departmentId
FROM (VALUES
    (1, 'Cardiology',       1),
    (1, 'General Medicine', 1),
    (2, 'Pediatrics',       2),
    (3, 'General Medicine', 2),
    (4, 'Neurology',        1),
    (5, 'Orthopedics',      2),
    (6, 'Oncology',         3),
    (7, 'Cardiology',       4)
) AS src(doctorId, departmentName, hospitalId)
INNER JOIN Departments dep
    ON dep.departmentName = src.departmentName
   AND dep.hospitalId     = src.hospitalId
WHERE NOT EXISTS (
    SELECT 1 FROM DoctorDepartment dd
    WHERE dd.doctorId     = src.doctorId
      AND dd.departmentId = dep.departmentId
);
GO


-- 10. DOCTOR — HOSPITAL LINKS (depends on Doctors, Hospitals)
--     DoctorHospital was added to model employment explicitly
INSERT INTO DoctorHospital (doctorId, hospitalId) VALUES
(1,  1), (1,  2),
(2,  2), (2,  5),
(3,  1),
(4,  4), (4,  6),
(5,  3), (5,  5),
(6,  7),
(7,  4), (7,  8),
(8,  8),
(9,  9), (9,  10),
(10, 10),
(11, 11), (11, 12),
(12,  1), (12, 11),
(13,  9),
(14,  6), (14, 12),
(15,  3),
(16,  7), (16,  2),
(17, 10), (17,  5),
(18, 12);
GO


-- 11. APPOINTMENTS
INSERT INTO Appointments (appointmentDateTime, purpose, [status], doctorId, patientId, hospitalId) VALUES
('2026-06-10 09:30:00', 'Annual Cardio Checkup',          'Scheduled', 1, 1, 1),
('2026-06-12 11:00:00', 'Chronic Fatigue Consultation',   'Scheduled', 3, 2, 2),
('2026-06-15 14:00:00', 'Paediatric Follow-up',           'Scheduled', 2, 3, 2);
GO


-- 12. VISITS
INSERT INTO Visits (visitDateTime, purpose, doctorId, patientId, insuranceId, hospitalId) VALUES
('2026-06-01 10:00:00', 'Severe chest tightness',      1, 1, 2, 1),
('2026-06-03 14:15:00', 'Routine blood glucose check', 3, 2, 1, 2);
GO


-- 13. PHARMACY INVENTORY (depends on Pharmacies, Medicines)
INSERT INTO PharmacyInventory (pharmacyId, medicineId, stockQuantity, unitPrice) VALUES
(1, 1, 120, 15.50),
(1, 2,   0, 12.00),
(2, 2,  85, 14.00),
(2, 3, 200, 22.10);
GO


-- 14. PRESCRIPTIONS (depends on Doctors, Patients, Insurances)
--     NOTE: medicineId column was removed from this table.
--     Medicines are now linked via PrescriptionMedicines below.
INSERT INTO Prescriptions (createdAt, doctorId, patientId, insuranceId) VALUES
('2026-06-01 10:45:00', 1, 1, 2),
('2026-06-03 14:45:00', 3, 2, 1);
GO


-- 15. PRESCRIPTION MEDICINES (depends on Prescriptions, Medicines)
--     Bridge table replacing the old single medicineId column.
--     A prescription can now carry multiple medicines.
INSERT INTO PrescriptionMedicines (prescriptionId, medicineId, dosage, durationDays, quantity) VALUES
(1, 3, '10mg once daily',          30, 30),
(1, 4, '500mg once daily',         30, 30),
(2, 1, '500mg three times daily',   7, 21),
(2, 2, '250mg twice daily',        10, 20);
GO


-- 16. PHARMACY SALES (depends on Pharmacies, Prescriptions)
INSERT INTO PharmacySales (pharmacyId, prescriptionId, saleDate, totalPaid) VALUES
(1, 2, '2026-06-03 16:00:00', 3.10);
GO

-- Keep in mind, this Data exists in the table already, running this script will create errors.