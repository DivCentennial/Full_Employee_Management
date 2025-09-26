@echo off
echo 🚀 Starting All Microservices...

echo Starting Authentication Service on port 7168...
start "Authentication Service" cmd /k "cd Authentication\ApiService && dotnet run"

timeout /t 3 /nobreak >nul

echo Starting Employee Service on port 7166...
start "Employee Service" cmd /k "cd Employee\ApiService && dotnet run"

timeout /t 3 /nobreak >nul

echo Starting Department Service on port 7167...
start "Department Service" cmd /k "cd Department\ApiService && dotnet run"

timeout /t 3 /nobreak >nul

echo Starting API Gateway on port 5000...
start "API Gateway" cmd /k "cd ApiGateway\ApiGateway && dotnet run"

timeout /t 10 /nobreak >nul

echo.
echo ✅ All Microservices Started Successfully!
echo.
echo 🌐 Service URLs:
echo • API Gateway: https://localhost:5000
echo • Authentication: https://localhost:7168
echo • Employee: https://localhost:7166
echo • Department: https://localhost:7167
echo.
echo 📱 Web UI: Open web-ui/index.html in your browser
echo.
echo Press any key to stop all services...
pause >nul

echo 🛑 Stopping all services...
taskkill /f /im dotnet.exe >nul 2>&1
echo All services stopped.
