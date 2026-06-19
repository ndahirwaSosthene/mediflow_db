-- Create performance indexes
-- Indexes on frequently linked or filtered transactional attributes
CREATE NONCLUSTERED INDEX IX_Appointments_DateTime ON Appointments(appointmentDateTime);
CREATE NONCLUSTERED INDEX IX_Visits_Patient ON Visits(patientId);
CREATE NONCLUSTERED INDEX INDEX_Medicines_Name ON Medicines(medicineName);
CREATE NONCLUSTERED INDEX IX_PharmacyInventory_Stock ON PharmacyInventory(stockQuantity);
CREATE NONCLUSTERED INDEX IX_DoctorHospital_Hospital ON DoctorHospital(hospitalId);
GO