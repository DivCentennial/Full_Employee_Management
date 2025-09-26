# Microservices Architecture with Ocelot API Gateway

This project demonstrates a microservices architecture with two services (Employee and Department) communicating through an Ocelot API Gateway.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │  Employee MS    │    │ Department MS   │
│   (Ocelot)      │    │   Port: 7166    │    │   Port: 7167    │
│   Port: 5000    │◄──►│                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Services

### 1. Employee Microservice
- **Port**: 7166 (HTTPS), 5222 (HTTP)
- **Features**: Full CRUD operations for employees
- **Endpoints**:
  - `GET /api/employee` - Get all employees
  - `GET /api/employee/{id}` - Get employee by ID
  - `POST /api/employee` - Create new employee
  - `PUT /api/employee/{id}` - Update employee
  - `DELETE /api/employee/{id}` - Delete employee

### 2. Department Microservice
- **Port**: 7167 (HTTPS), 5223 (HTTP)
- **Features**: Full CRUD operations for departments
- **Endpoints**:
  - `GET /api/department` - Get all departments
  - `GET /api/department/{id}` - Get department by ID
  - `POST /api/department` - Create new department
  - `PUT /api/department/{id}` - Update department
  - `DELETE /api/department/{id}` - Delete department

### 3. API Gateway (Ocelot)
- **Port**: 5000 (HTTPS), 5001 (HTTP)
- **Features**: Routes requests to appropriate microservices
- **Routes**:
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
# Terminal 1 - Start Employee Service
cd Employee/ApiService
dotnet run

# Terminal 2 - Start Department Service  
cd Department/ApiService
dotnet run

# Terminal 3 - Start API Gateway
cd ApiGateway/ApiGateway
dotnet run
```

### Testing the Services

#### Direct Service Access
```bash
# Employee Service
curl https://localhost:7166/api/employee

# Department Service
curl https://localhost:7167/api/department
```

#### Through API Gateway
```bash
# Employee Service via Gateway
curl https://localhost:5000/api/employee

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

## Benefits of This Architecture

1. **Service Isolation**: Each microservice is independent and can be developed/deployed separately
2. **API Gateway**: Single entry point for all client requests
3. **Load Balancing**: Ocelot can distribute requests across multiple instances
4. **Cross-Cutting Concerns**: Authentication, logging, rate limiting can be handled at the gateway level
5. **Service Discovery**: Easy to add/remove services without changing client code

## Next Steps

1. **Add Authentication**: Implement JWT authentication at the API Gateway level
2. **Service Discovery**: Use Consul or Eureka for dynamic service discovery
3. **Health Checks**: Add health check endpoints for monitoring
4. **Logging**: Implement centralized logging with Serilog
5. **Docker**: Containerize all services for easy deployment
6. **Database**: Add real database connections instead of in-memory data

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 5000, 7166, and 7167 are available
2. **SSL Certificates**: The test script uses `-SkipCertificateCheck` for development
3. **Service Startup Order**: Start services in order: Employee → Department → API Gateway

### Build Issues
```bash
# Clean and rebuild
dotnet clean MicroservicesSolution.sln
dotnet build MicroservicesSolution.sln
```
