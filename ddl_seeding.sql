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
