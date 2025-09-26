# Manual Service Startup Commands

## Start All Services Manually

### 1. Authentication Service
```powershell
cd Authentication\ApiService
dotnet run
```

### 2. Employee Service (New Terminal)
```powershell
cd Employee\ApiService
dotnet run
```

### 3. Department Service (New Terminal)
```powershell
cd Department\ApiService
dotnet run
```

### 4. API Gateway (New Terminal)
```powershell
cd ApiGateway\ApiGateway
dotnet run
```

## Service URLs
- **API Gateway**: https://localhost:5000
- **Authentication**: https://localhost:7168
- **Employee**: https://localhost:7166
- **Department**: https://localhost:7167

## Web UI
Open `web-ui/index.html` in your browser

## Stop All Services
```powershell
Get-Process -Name "dotnet" | Stop-Process -Force
```
