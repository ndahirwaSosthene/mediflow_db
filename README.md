# MediflowDB

A relational database system for a national medical ecosystem, built on Microsoft SQL Server. MediflowDB serves as the backend data layer for Mediflow — a platform that centralises operations across four key stakeholders: hospitals, patients, insurance providers, and pharmacies.

This project was developed as a final assignment for the Databases course at Vizja University, Warsaw.

---

## Overview

The medical sector involves complex transactions between multiple parties. A patient visits a hospital, a doctor issues a prescription, a pharmacy fulfils it, and an insurance provider covers part of the cost. MediflowDB models all of these interactions in a single, normalised relational schema.

The system deliberately focuses on the **transactional relationships** between stakeholders rather than clinical data such as diagnoses or disease catalogues. Those would belong to a separate clinical information system integrated via API in a production environment.

---

## Database Structure

The schema consists of 16 tables organised into three categories.

**Primary stakeholder tables** — the four core entities of the ecosystem:
`Hospitals`, `Patients`, `Insurances`, `Pharmacies`

**Operational entity tables** — entities that support stakeholder interactions:
`Doctors`, `Departments`, `Medicines`, `Appointments`, `Visits`, `Prescriptions`, `PharmacySales`

**Bridge / junction tables** — resolving many-to-many relationships:
`DoctorDepartment`, `HospitalInsurance`, `PharmacyInventory`, `DoctorHospital`, `PrescriptionMedicines`

The schema follows **Third Normal Form (3NF)** throughout. Every non-key column depends solely on the primary key of its table, with no transitive dependencies.

Key design decisions are documented in the technical report under `docs/`.

---

## What Is Included

```
MediflowDB/
│
├── schema/
│   ├── 01_create_database.sql        -- database creation
│   ├── 02_create_tables.sql          -- all 16 tables with keys and constraints
│   ├── 03_indexes_constraints.sql    -- non-clustered indexes
│   └── 04_sample_data.sql            -- seed data for all tables
│
├── views/
│   └── 05_views.sql                  -- 3 views (JOIN, UNION, subquery-based)
│
├── programmable_objects/
│   ├── 06_stored_procedures.sql      -- 3 custom stored procedures
│   ├── 07_triggers.sql               -- 3 automated triggers
│   └── 08_backup_procedure.sql       -- rolling backup engine (30-file rotation)
│
├── security/
│   ├── 09_roles_permissions.sql      -- 3 roles with scoped permissions
│   └── 10_users.sql                  -- 3 users assigned to roles
│
├── queries/
│   ├── 11_subqueries.sql             -- 3 standalone analytical subqueries
│   ├── 12_aggregate_queries.sql      -- queries using DISTINCT, MIN, MAX, AVG,
│   │                                    COUNT, HAVING, SELECT TOP, EXISTS, CASE
│   └── 13_system_procedures.sql      -- 10 system stored procedures with usage
│
├── docs/
│   └── Mediflow_Report.docx          -- full technical report
│
└── backup/
    └── MediflowDB_Week_1.bak         -- sample database backup file
```

---

## How to Run

**Requirements:** Microsoft SQL Server (any edition) with SQL Server Management Studio (SSMS).

Run the scripts in the numbered order below. Each script depends on the objects created by the one before it.

```
1. schema/01_create_database.sql
2. schema/02_create_tables.sql
3. schema/03_indexes_constraints.sql
4. schema/04_sample_data.sql
5. views/05_views.sql
6. programmable_objects/06_stored_procedures.sql
7. programmable_objects/07_triggers.sql
8. programmable_objects/08_backup_procedure.sql
9. security/09_roles_permissions.sql
10. security/10_users.sql
11. queries/11_subqueries.sql
12. queries/12_aggregate_queries.sql
13. queries/13_system_procedures.sql
```

Open each file in SSMS, ensure you are connected to the correct instance, and press F5 to execute.

**Note on the backup script:** Before running `08_backup_procedure.sql`, create a folder on your machine where backup files will be written, then update the `@BaseDirectory` variable inside `sp_ExecuteRollingBackup` to point to that folder. The SQL Server service account must have write access to that directory.

---

## Programmable Objects

**Views**
- `v_DoctorPrescriptionHelper` — shows medicines currently in stock across pharmacies, used by doctors before issuing a prescription
- `v_EcosystemEmergencyDirectory` — unified contact registry merging hospitals, pharmacies, and doctors via UNION
- `v_HighRiskPatientCareTracker` — upcoming appointments for allergy-flagged patients with active visit histories, using a correlated subquery

**Stored Procedures**
- `sp_AddNewAppointment` — books an appointment with built-in past-date validation
- `sp_AddNewMedicineToPharmacyStock` — synchronises the global medicine catalogue with a pharmacy's local inventory using an upsert pattern inside a transaction
- `sp_FindNearbyPharmacies` — accepts a hospital name, extracts the district from its address, and returns pharmacies in the same area

**Triggers**
- `tr_LowStockAlert` — fires after any inventory update; logs a warning to `SupplyAlerts` when stock drops below 15 units
- `tr_PatientAuditTrail` — fires after any patient record update; logs the old and new allergy value with timestamp and user to `MedicalAuditLogs`
- `tr_AutoGenerateBilling` — fires after every new appointment insert; automatically creates a billing record in `Invoices`

---

## Access Control

Three roles are defined with scoped permissions:

| Role | Access |
|---|---|
| `MediflowAdmin` | Full read and write across all tables |
| `HospitalAdmin` | Clinical tables only — patients, appointments, visits, doctors |
| `PharmacyAdmin` | Pharmacy tables only — inventory, sales, prescriptions (read) |

One user is assigned to each role: `sys_admin_mediflow`, `staff_hospital_01`, `staff_pharmacy_01`.

---

## Possible Extensions

- **District-level proximity search** — the current `sp_FindNearbyPharmacies` procedure uses string matching on a combined address field. Splitting address into structured columns (street, postal code, district) would enable higher-precision queries.
- **Patient registration pipeline** — an INSTEAD OF trigger on a registration view could automatically route incoming patient and appointment data to the correct tables without requiring the application layer to manage ID lookups.
- **SQL Server Agent scheduling** — the rolling backup procedure currently runs manually. In production it would be bound to a weekly Agent job or a Windows Task Scheduler entry via SQLCMD.
- **Clinical system integration** — a REST API layer connecting MediflowDB to a separate clinical information system would allow diagnostic codes and medical records to be referenced without duplicating clinical data inside this schema.

---

## Technical Report

The full technical report is available in `docs/Mediflow_Report.docx`. It covers the database design decisions, schema diagram, description of all scripts, role and permission gradations, problems encountered during development, and conclusions.

---

## Author

INEZA Ndahirwa Sosthene  
Databases course — Vizja University, Warsaw  
2025 / 2026