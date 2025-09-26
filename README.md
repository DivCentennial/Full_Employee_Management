<<<<<<< HEAD
# Microservices Architecture with Ocelot API Gateway

This project demonstrates a microservices architecture with three services (Authentication, Employee, and Department) communicating through an Ocelot API Gateway, featuring JWT authentication, role-based authorization, and bulk user registration.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │ Authentication  │    │  Employee MS    │    │ Department MS   │
│   (Ocelot)      │    │   Port: 7168    │    │   Port: 7166    │    │   Port: 7167    │
│   Port: 5000    │◄──►│                 │◄──►│                 │◄──►│                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Services

### 1. Authentication Microservice
- **Port**: 7168 (HTTPS), 5224 (HTTP)
- **Features**: User authentication, JWT token generation, bulk user registration
- **Endpoints**:
  - `POST /api/authentication/register` - Register new user
  - `POST /api/authentication/login` - User login
  - `POST /api/authentication/bulk-register` - Bulk user registration via JSON file
  - `GET /api/authentication/validate-json` - Show JSON format for bulk upload
  - `GET /api/authentication/user-exists/{username}` - Check if user exists
  - `GET /api/authentication/user-info/{username}` - Get user information

### 2. Employee Microservice
- **Port**: 7166 (HTTPS), 5222 (HTTP)
- **Features**: Full CRUD operations for employees with role-based authorization
- **Endpoints**:
  - `GET /api/employee` - Get all employees (requires authentication)
  - `GET /api/employee/{id}` - Get employee by ID (requires authentication)
  - `POST /api/employee` - Create new employee (admin only)
  - `PUT /api/employee/{id}` - Update employee (admin only)
  - `DELETE /api/employee/{id}` - Delete employee (admin only)
  - `GET /api/employee/with-dept-simple` - Get employees with department info

### 3. Department Microservice
- **Port**: 7167 (HTTPS), 5223 (HTTP)
- **Features**: Full CRUD operations for departments with hard token validation
- **Endpoints**:
  - `GET /api/department` - Get all departments
  - `GET /api/department/{id}` - Get department by ID
  - `POST /api/department` - Create new department
  - `PUT /api/department/{id}` - Update department
  - `DELETE /api/department/{id}` - Delete department

### 4. API Gateway (Ocelot)
- **Port**: 5000 (HTTPS), 5001 (HTTP)
- **Features**: Routes requests to appropriate microservices with authentication
- **Routes**:
  - `/api/authentication/*` → Authentication Service (port 7168)
  - `/api/employee/*` → Employee Service (port 7166)
  - `/api/department/*` → Department Service (port 7167)

## Project Structure

```
microservices_mariapps/
├── ApiGateway/
│   └── ApiGateway/
│       ├── ocelot.json          # Ocelot routing configuration
│       ├── Program.cs           # API Gateway startup
│       └── ApiGateway.csproj
├── Authentication/
│   ├── ApiService/              # Authentication API
│   ├── Business/                # Authentication business logic
│   ├── DataCarrier/             # User entities
│   ├── DataModel/               # Auth DTOs
│   ├── Repository/              # User data access
│   └── Repository.Contracts/    # Repository interfaces
├── Employee/
│   ├── ApiService/              # Employee API
│   ├── Business/                # Employee business logic
│   ├── DataCarrier/             # Employee entities
│   ├── DataModel/               # Employee DTOs
│   ├── Repository/              # Employee data access
│   └── Repository.Contracts/    # Employee repository interfaces
├── Department/
│   ├── ApiService/              # Department API
│   ├── Business/                # Department business logic
│   ├── DataCarrier/             # Department entities
│   ├── DataModel/               # Department DTOs
│   ├── Repository/              # Department data access
│   └── Repository.Contracts/    # Department repository interfaces
├── web-ui/                      # Frontend web interface
│   ├── index.html               # Main UI
│   ├── script.js                # JavaScript logic
│   ├── styles.css               # CSS styling
│   └── sample-users.json        # Sample JSON for bulk upload
├── database-scripts-corrected.sql # Database setup scripts
└── MicroservicesSolution.sln    # Master solution file
```

## Getting Started

### Prerequisites
- .NET 8.0 SDK
- PowerShell (for test script)

### Running the Services

#### Option 1: Using the Test Script (Recommended)
```powershell
# Run the automated test script
.\test-microservices.ps1
```

#### Option 2: Manual Startup
```bash
# Terminal 1 - Start Authentication Service
cd Authentication/ApiService
dotnet run

# Terminal 2 - Start Employee Service
cd Employee/ApiService
dotnet run

# Terminal 3 - Start Department Service  
cd Department/ApiService
dotnet run

# Terminal 4 - Start API Gateway
cd ApiGateway/ApiGateway
dotnet run
```

### Testing the Services

#### Direct Service Access
```bash
# Authentication Service
curl -X POST https://localhost:7168/api/authentication/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Employee Service (requires authentication)
curl https://localhost:7166/api/employee \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Department Service
curl https://localhost:7167/api/department
```

#### Through API Gateway
```bash
# Authentication Service via Gateway
curl -X POST https://localhost:5000/api/authentication/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Employee Service via Gateway (requires authentication)
curl https://localhost:5000/api/employee \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Department Service via Gateway
curl https://localhost:5000/api/department
```

## API Gateway Configuration

The Ocelot configuration in `ocelot.json` defines the routing rules:

```json
{
  "Routes": [
    {
      "DownstreamPathTemplate": "/api/{everything}",
      "DownstreamScheme": "https",
      "DownstreamHostAndPorts": [
        {
          "Host": "localhost",
          "Port": 7166
        }
      ],
      "UpstreamPathTemplate": "/api/employee/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST", "PUT", "DELETE" ]
    },
    {
      "DownstreamPathTemplate": "/api/{everything}",
      "DownstreamScheme": "https", 
      "DownstreamHostAndPorts": [
        {
          "Host": "localhost",
          "Port": 7167
        }
      ],
      "UpstreamPathTemplate": "/api/department/{everything}",
      "UpstreamHttpMethod": [ "GET", "POST", "PUT", "DELETE" ]
    }
  ]
}
```

## New Features

### Bulk User Registration
- **JSON File Upload**: Upload JSON files to register multiple users at once
- **Format Validation**: Automatic validation of JSON structure and required fields
- **User-to-Endpoint Mapping**: Map users to specific API endpoints with hard tokens
- **Database Integration**: Store user permissions and API access in database tables

### Authentication & Authorization
- **JWT Token-Based Authentication**: Secure token-based authentication system
- **Role-Based Access Control**: Admin and user roles with different permissions
- **Permission-Based API Access**: Fine-grained control over API endpoint access
- **Hard Token Validation**: Inter-service communication using hard tokens
- **Filtered JWT Tokens**: Minimal token payload for security and performance

### Web Interface
- **Simple Web UI**: Easy-to-use interface for testing all microservices
- **Real-Time Testing**: Test authentication, employee, and department APIs
- **File Upload Interface**: Upload JSON files for bulk user registration
- **Token Management**: View and manage JWT tokens
- **Response Display**: Clear display of API responses and errors

## Benefits of This Architecture

1. **Service Isolation**: Each microservice is independent and can be developed/deployed separately
2. **API Gateway**: Single entry point for all client requests with authentication
3. **Load Balancing**: Ocelot can distribute requests across multiple instances
4. **Cross-Cutting Concerns**: Authentication, logging, rate limiting can be handled at the gateway level
5. **Service Discovery**: Easy to add/remove services without changing client code
6. **Security**: JWT authentication with role-based authorization
7. **Scalability**: Bulk user registration and database-driven permissions

## Web Interface Usage

### Accessing the Web UI
1. **Open**: Navigate to the `web-ui/` folder and open `index.html` in a web browser
2. **Login**: Use existing credentials or register new users
3. **Test APIs**: Use the interface to test all microservices
4. **Upload Files**: Use the bulk registration feature to upload JSON files

### JSON File Format for Bulk Upload
```json
[
  {
    "UserName": "admin",
    "Email": "admin@company.com",
    "Password": "AdminPassword123",
    "Role": "admin",
    "Endpoints": [
      "/api/employee",
      "/api/department"
    ]
  },
  {
    "UserName": "user1",
    "Email": "user1@company.com",
    "Password": "UserPassword123",
    "Role": "user",
    "Endpoints": [
      "/api/employee"
    ]
  }
]
```

## Database Setup

### Running Database Scripts
1. **Execute**: Run `database-scripts-corrected.sql` in your SQL Server
2. **Tables Created**: 
   - `Employee_Details` (existing)
   - `API` (new)
   - `Mapping` (new)
3. **Sample Data**: Script includes sample API endpoints and mappings

## Next Steps

1. **Database Integration**: Complete the database integration for bulk user registration
2. **Service Discovery**: Use Consul or Eureka for dynamic service discovery
3. **Health Checks**: Add health check endpoints for monitoring
4. **Logging**: Implement centralized logging with Serilog
5. **Docker**: Containerize all services for easy deployment
6. **Production Database**: Connect to production database instead of in-memory data

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 5000, 7166, 7167, and 7168 are available
2. **SSL Certificates**: The test script uses `-SkipCertificateCheck` for development
3. **Service Startup Order**: Start services in order: Authentication → Employee → Department → API Gateway
4. **CORS Issues**: If web UI doesn't work, try opening Chrome with disabled security: `chrome.exe --disable-web-security --user-data-dir="C:/temp"`
5. **Authentication Errors**: Ensure you're logged in before accessing protected endpoints
6. **File Upload Issues**: Check that JSON file format matches the expected structure

### Build Issues
```bash
# Clean and rebuild
dotnet clean MicroservicesSolution.sln
dotnet build MicroservicesSolution.sln
```
=======
# Full_Employee_Management
So its a full employee management web app with both frontend and backend.
>>>>>>> bdea7e2f63d1c7885ef3503a01e01f6e89c85c45
