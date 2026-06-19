-- 1. sp_help
/*
    Shows a summary of any database object(table): its columns,
    data types, constraints, and indexes.
*/
EXEC sp_help 'Patients';
GO


-- 2. sp_helpdb
/*
    Displays information about a specific database:
    its size, owner, creation date, and configuration options.
*/
EXEC sp_helpdb 'MediflowDB';
GO


-- 3. sp_helptext
/*
    Returns the source code (definition) of a stored procedure,
    view, trigger, or function stored in the database.
*/
EXEC sp_helptext 'sp_ExecuteRollingBackup';
GO


-- 4. sp_who
/*Lists all current users and processes active on the
    SQL Server instance, including their login name,
    status, and which database they are connected to.
*/
EXEC sp_who;
GO


-- 5. sp_spaceused
/*
    Reports how much disk space a table or the entire database
    is using, including reserved space, data space,
    index space, and unused space.
*/
EXEC sp_spaceused 'Visits';
GO


-- 6. sp_tables
/*
    Returns a list of all tables and views available in the
    current database that can be queried.
*/
EXEC sp_tables;
GO


/*
7. sp_columns
    Returns detailed column metadata for a specific table:
    column names, data types, lengths, nullability, and defaults.
*/
EXEC sp_columns 'Prescriptions';
GO


-- 8. sp_helpconstraint
/*
    Lists all constraints on a given table: primary keys,
    foreign keys, unique constraints, and check constraints.
*/
EXEC sp_helpconstraint 'Appointments';
GO


-- 9. sp_rename
/*
    Renames an existing database object or column.
    Here we rename a column as a demonstration, then rename
    it back to keep the schema intact.
*/

-- Rename contactPhone to phoneNumber in Doctors
EXEC sp_rename 'Doctors.contactPhone', 'phoneNumber', 'COLUMN';
GO

-- Rename it back to restore the original schema
EXEC sp_rename 'Doctors.phoneNumber', 'contactPhone', 'COLUMN';
GO


/*
    10. sp_depends
    Shows all objects that depend on a given object, or all
    objects that a given object depends on.
*/
EXEC sp_depends 'Patients';
GO