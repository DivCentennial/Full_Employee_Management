-- Database Tables for File Upload Feature
-- Employee_Details, API, and Mapping tables

-- 1. Employee_Details Table
CREATE TABLE Employee_Details (
    EmpId INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) NOT NULL DEFAULT 'user',
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- 2. API Table
CREATE TABLE API (
    ApiId INT IDENTITY(1,1) PRIMARY KEY,
    Endpoint NVARCHAR(500) NOT NULL,
    Description NVARCHAR(1000) NULL,
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- 3. Mapping Table (links Employee ↔ API)
CREATE TABLE Mapping (
    MappingId INT IDENTITY(1,1) PRIMARY KEY,
    EmpId INT NOT NULL,
    ApiId INT NOT NULL,
    HardToken UNIQUEIDENTIFIER NOT NULL DEFAULT '88B367A8-99D4-44E1-BDE7-A233E225024E',
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    -- Foreign Key Constraints
    FOREIGN KEY (EmpId) REFERENCES Employee_Details(EmpId),
    FOREIGN KEY (ApiId) REFERENCES API(ApiId),
    
    -- Unique constraint to prevent duplicate mappings
    UNIQUE (EmpId, ApiId)
);

-- Indexes for better performance
CREATE INDEX IX_Employee_Details_UserName ON Employee_Details(UserName);
CREATE INDEX IX_Employee_Details_Email ON Employee_Details(Email);
CREATE INDEX IX_API_Endpoint ON API(Endpoint);
CREATE INDEX IX_Mapping_EmpId ON Mapping(EmpId);
CREATE INDEX IX_Mapping_ApiId ON Mapping(ApiId);
CREATE INDEX IX_Mapping_HardToken ON Mapping(HardToken);

-- Sample data for testing
INSERT INTO API (Endpoint, Description) VALUES 
('/api/employee', 'Employee management endpoints'),
('/api/department', 'Department management endpoints'),
('/api/authentication', 'Authentication endpoints');

-- Sample employee
INSERT INTO Employee_Details (UserName, Email, Password, Role) VALUES 
('admin', 'admin@example.com', 'hashed_password_here', 'admin');

-- Sample mapping
INSERT INTO Mapping (EmpId, ApiId) VALUES 
(1, 1), -- admin can access /api/employee
(1, 2), -- admin can access /api/department
(1, 3); -- admin can access /api/authentication
