# PowerShell script to start all microservices
Write-Host "🚀 Starting All Microservices..." -ForegroundColor Green

# Start Authentication Service
Write-Host "Starting Authentication Service on port 7168..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Authentication/ApiService/ApiService.csproj" -WindowStyle Normal

# Wait a bit for Authentication service to start
Start-Sleep -Seconds 3

# Start Employee Service
Write-Host "Starting Employee Service on port 7166..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Employee/ApiService/ApiService.csproj" -WindowStyle Normal

# Wait a bit for Employee service to start
Start-Sleep -Seconds 3

# Start Department Service  
Write-Host "Starting Department Service on port 7167..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Department/ApiService/ApiService.csproj" -WindowStyle Normal

# Wait a bit for Department service to start
Start-Sleep -Seconds 3

# Start API Gateway
Write-Host "Starting API Gateway on port 5000..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project ApiGateway/ApiGateway/ApiGateway.csproj" -WindowStyle Normal

# Wait for all services to start
Write-Host "Waiting for all services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host "`n✅ All Microservices Started Successfully!" -ForegroundColor Green
Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "• API Gateway: https://localhost:5000" -ForegroundColor White
Write-Host "• Authentication: https://localhost:7168" -ForegroundColor White
Write-Host "• Employee: https://localhost:7166" -ForegroundColor White
Write-Host "• Department: https://localhost:7167" -ForegroundColor White

Write-Host "`n📱 Web UI: Open web-ui/index.html in your browser" -ForegroundColor Yellow

Write-Host "`nPress Ctrl+C to stop all services..." -ForegroundColor Red

# Keep the script running and wait for user to stop
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "`n🛑 Stopping all services..." -ForegroundColor Yellow
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "All services stopped." -ForegroundColor Green
}
