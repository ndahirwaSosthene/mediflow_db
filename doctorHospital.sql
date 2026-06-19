-- ============================================================
-- CREATE TABLE
-- ============================================================
IF OBJECT_ID('DoctorHospital', 'U') IS NOT NULL
    DROP TABLE DoctorHospital;
GO

CREATE TABLE DoctorHospital (
    doctorId   INT NOT NULL,
    hospitalId INT NOT NULL,
    CONSTRAINT PK_DoctorHospital PRIMARY KEY (doctorId, hospitalId),
    CONSTRAINT FK_DoctorHospital_Doctors   FOREIGN KEY (doctorId)   REFERENCES Doctors(doctorId),
    CONSTRAINT FK_DoctorHospital_Hospitals FOREIGN KEY (hospitalId) REFERENCES Hospitals(hospitalId)
);
GO

-- Index for lookups by hospital (e.g. "show all doctors at hospital X")
CREATE NONCLUSTERED INDEX IX_DoctorHospital_Hospital
ON DoctorHospital(hospitalId);
GO


-- ============================================================
-- SEED DATA
-- Distributing 18 doctors across 12 hospitals.
-- Several doctors work at multiple hospitals to correctly
-- demonstrate the M:N relationship.
-- ============================================================
INSERT INTO DoctorHospital (doctorId, hospitalId) VALUES

-- John Smith (1) -> Okopowa General, Torunska Medical
(1, 1), (1, 2),

-- Elena Russo (2) -> Torunska Medical, Wolska Regional
(2, 2), (2, 5),

-- David Kim (3) -> Okopowa General
(3, 1),

-- Anna Kowalska (4) -> Dr. Warszawa, Pulawska Health Clinic
(4, 4), (4, 6),

-- Jan Nowak (5) -> New life, Wolska Regional
(5, 3), (5, 5),

-- Maria Wisniewska (6) -> Marszalkowska Medical Institute
(6, 7),

-- Piotr Wójcik (7) -> Dr. Warszawa, Grochowska Community
(7, 4), (7, 8),

-- Katarzyna Kaminska (8) -> Grochowska Community
(8, 8),

-- Tomasz Lewandowski (9) -> Targowa Specialist, Zwirki i Wigury
(9, 9), (9, 10),

-- Aleksandra Zielinska (10) -> Zwirki i Wigury
(10, 10),

-- Jakub Szymanski (11) -> Modlinska Healthcare, Aleja Solidarnosci
(11, 11), (11, 12),

-- Magdalena Wozniak (12) -> Okopowa General, Modlinska Healthcare
(12, 1), (12, 11),

-- Michal Kozlowski (13) -> Targowa Specialist
(13, 9),

-- Agnieszka Jankowska (14) -> Pulawska Health Clinic, Aleja Solidarnosci
(14, 6), (14, 12),

-- Mateusz Mazur (15) -> New life
(15, 3),

-- Zuzanna Krawczyk (16) -> Marszalkowska Medical Institute, Torunska Medical
(16, 7), (16, 2),

-- Filip Piotrowski (17) -> Zwirki i Wigury, Wolska Regional
(17, 10), (17, 5),

-- Julia Grabowska (18) -> Aleja Solidarnosci
(18, 12);
GO


-- ============================================================
-- VERIFICATION QUERIES
-- Run these after inserting to confirm the data looks correct
-- ============================================================

-- See all doctor-hospital assignments with names
SELECT
    d.doctorId,
    d.firstName + ' ' + d.lastName AS DoctorName,
    h.hospitalId,
    h.hospitalName
FROM DoctorHospital dh
INNER JOIN Doctors   d ON dh.doctorId   = d.doctorId
INNER JOIN Hospitals h ON dh.hospitalId = h.hospitalId
ORDER BY d.doctorId;
GO

-- Count how many doctors each hospital has
SELECT
    h.hospitalName,
    COUNT(dh.doctorId) AS DoctorCount
FROM DoctorHospital dh
INNER JOIN Hospitals h ON dh.hospitalId = h.hospitalId
GROUP BY h.hospitalName
ORDER BY DoctorCount DESC;
GO