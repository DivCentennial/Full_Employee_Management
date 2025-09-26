-- Corrected Database Scripts for File Upload Feature
-- Working with existing Employee_Details table structure

-- First, let's check what foreign key constraints exist on the API table
-- and drop them before dropping the table

-- 1. Drop foreign key constraints that reference the API table
DECLARE @sql NVARCHAR(MAX) = ''
SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys 
WHERE referenced_object_id = OBJECT_ID('API')

IF @sql <> ''
BEGIN
    PRINT 'Dropping foreign key constraints:'
    PRINT @sql
    EXEC sp_executesql @sql
END

-- 2. Now drop the API table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'API') AND type in (N'U'))
BEGIN
    DROP TABLE API;
    PRINT 'API table dropped successfully'
END

-- 3. Create the new API table with correct structure
CREATE TABLE API (
    ApiId INT IDENTITY(1,1) PRIMARY KEY,
    Endpoint NVARCHAR(500) NOT NULL,
    Description NVARCHAR(1000) NULL,
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- 4. Create the Mapping table (links Employee ↔ API)
-- Note: We'll use the existing Empid from Employee_Details table
CREATE TABLE Mapping (
    MappingId INT IDENTITY(1,1) PRIMARY KEY,
    EmpId INT NOT NULL,
    ApiId INT NOT NULL,
    HardToken UNIQUEIDENTIFIER NOT NULL DEFAULT '88B367A8-99D4-44E1-BDE7-A233E225024E',
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    -- Foreign Key Constraints
    FOREIGN KEY (EmpId) REFERENCES Employee_Details(Empid),
    FOREIGN KEY (ApiId) REFERENCES API(ApiId),
    
    -- Unique constraint to prevent duplicate mappings
    UNIQUE (EmpId, ApiId)
);

-- 5. Indexes for better performance
CREATE INDEX IX_API_Endpoint ON API(Endpoint);
CREATE INDEX IX_Mapping_EmpId ON Mapping(EmpId);
CREATE INDEX IX_Mapping_ApiId ON Mapping(ApiId);
CREATE INDEX IX_Mapping_HardToken ON Mapping(HardToken);

-- 6. Sample data for testing
INSERT INTO API (Endpoint, Description) VALUES 
('/api/employee', 'Employee management endpoints'),
('/api/department', 'Department management endpoints'),
('/api/authentication', 'Authentication endpoints');

-- 7. Sample mapping for existing employees
-- Map employee ID 1 (Divyanshoo Sinha) to all APIs
INSERT INTO Mapping (EmpId, ApiId) VALUES 
(1, 1), -- Divyanshoo can access /api/employee
(1, 2), -- Divyanshoo can access /api/department
(1, 3); -- Divyanshoo can access /api/authentication

-- Map employee ID 2 (Bindu Madhu) to employee API only
INSERT INTO Mapping (EmpId, ApiId) VALUES 
(2, 1); -- Bindu can access /api/employee

-- 8. Verify the tables were created correctly
SELECT 'API Table' as TableName, COUNT(*) as RecordCount FROM API
UNION ALL
SELECT 'Mapping Table' as TableName, COUNT(*) as RecordCount FROM Mapping;

-- 9. Show sample data
SELECT 'API Endpoints:' as Info;
SELECT ApiId, Endpoint, Description FROM API;

SELECT 'Employee Mappings:' as Info;
SELECT m.MappingId, e.Ename as EmployeeName, a.Endpoint, m.HardToken 
FROM Mapping m
JOIN Employee_Details e ON m.EmpId = e.Empid
JOIN API a ON m.ApiId = a.ApiId;
