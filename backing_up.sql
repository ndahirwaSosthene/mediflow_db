-- 1. Create a persistent configuration table to track backup cycles
IF OBJECT_ID('BackupRotation', 'U') IS NOT NULL
    DROP TABLE BackupRotation;
GO

CREATE TABLE BackupRotation (
    rotationId INT IDENTITY(1,1) PRIMARY KEY,
    currentFileNumber INT NOT NULL CONSTRAINT CHK_MaxFiles CHECK (currentFileNumber BETWEEN 1 AND 30),
    lastBackupDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Seed the configuration table with file number 1
INSERT INTO BackupRotation (currentFileNumber) VALUES (1);
GO


-- 2. Create the Stored Procedure that executes the dynamic rolling backup
IF OBJECT_ID('sp_ExecuteRollingBackup', 'P') IS NOT NULL
    DROP PROCEDURE sp_ExecuteRollingBackup;
GO

CREATE PROCEDURE sp_ExecuteRollingBackup
AS
BEGIN
    SET NOCOUNT ON;

    -- =========================================================================
    -- CONFIGURATION: EDIT YOUR FILE PATH HERE
    -- Ensure this folder physically exists on your hard drive before executing!
    -- Always make sure the path ends with a backslash (\)
    -- =========================================================================
    DECLARE @BaseDirectory NVARCHAR(255) = N'C:\MediflowBackups\';
    -- =========================================================================

    DECLARE @FileNumber INT;
    DECLARE @BackupPath NVARCHAR(500);
    DECLARE @DynamicSQL NVARCHAR(MAX);

    -- Retrieve the current sequence number from our tracking table
    SELECT @FileNumber = currentFileNumber FROM BackupRotation WHERE rotationId = 1;

    -- Construct the exact historical filename (e.g., Mediflow_Week_1.bak)
    SET @BackupPath = @BaseDirectory + N'Mediflow_Week_' + CAST(@FileNumber AS NVARCHAR(2)) + N'.bak';

    -- Build the raw T-SQL backup statement dynamically
    -- 'WITH INIT' wipes out the contents of the file if it exists, fulfilling the max 30 requirement
    SET @DynamicSQL = N'BACKUP DATABASE [MediflowDB] TO DISK = ''' + @BackupPath + N''' WITH INIT, COMPRESSION, STATS = 10;';

    BEGIN TRY
        -- Execute the compiled backup query string
        EXEC sp_executesql @DynamicSQL;

        -- Calculate the next sequential position
        DECLARE @NextFileNumber INT = @FileNumber + 1;
        
        -- Reset mechanism: If the counter hits 31, loop back to file 1
        IF @NextFileNumber > 30 
            SET @NextFileNumber = 1;

        -- Update the state tracker for next week's operational execution
        UPDATE BackupRotation
        SET currentFileNumber = @NextFileNumber,
            lastBackupDate = GETDATE()
        WHERE rotationId = 1;

        PRINT '------------------------------------------------------------';
        PRINT 'SUCCESS: Mediflow rolling backup written to position slot ' + CAST(@FileNumber AS VARCHAR(2));
        PRINT 'File saved safely at: ' + @BackupPath;
        PRINT 'Next run will target slot: ' + CAST(@NextFileNumber AS VARCHAR(2));
        PRINT '------------------------------------------------------------';
    END TRY
    BEGIN CATCH
        -- Clear, descriptive troubleshooting messages for your assignment execution
        PRINT '------------------------------------------------------------';
        PRINT 'CRITICAL ERROR: Automated backup failed.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Troubleshooting Tips:';
        PRINT ' 1. Verify that the directory path ''' + @BaseDirectory + ''' physically exists on your drive.';
        PRINT ' 2. Ensure SQL Server has administrative permission to write to that folder.';
        PRINT '------------------------------------------------------------';
    END CATCH
END;
GO