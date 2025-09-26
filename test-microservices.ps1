# PowerShell script to test microservices communication through Ocelot API Gateway

Write-Host "Starting Microservices Test..." -ForegroundColor Green

# Start Authentication Service
Write-Host "Starting Authentication Service on port 7168..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Authentication/ApiService/ApiService.csproj" -WindowStyle Minimized

# Wait a bit for Authentication service to start
Start-Sleep -Seconds 3

# Start Employee Service
Write-Host "Starting Employee Service on port 7166..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Employee/ApiService/ApiService.csproj" -WindowStyle Minimized

# Wait a bit for Employee service to start
Start-Sleep -Seconds 3

# Start Department Service  
Write-Host "Starting Department Service on port 7167..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project Department/ApiService/ApiService.csproj" -WindowStyle Minimized

# Wait a bit for Department service to start
Start-Sleep -Seconds 3

# Start API Gateway
Write-Host "Starting API Gateway on port 5000..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --project ApiGateway/ApiGateway/ApiGateway.csproj" -WindowStyle Minimized

# Wait for all services to start
Write-Host "Waiting for all services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host "`nTesting API Gateway Routes:" -ForegroundColor Green

# Test Authentication Service through API Gateway
Write-Host "`n1. Testing Authentication Service through API Gateway:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://localhost:5000/api/authentication" -Method GET -SkipCertificateCheck
    Write-Host "✅ Authentication Service Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Authentication Service Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Filtered JWT Token Approach
Write-Host "`n1.1. Testing Filtered JWT Token Approach:" -ForegroundColor Cyan
try {
    # Test login to get filtered token for regular user
    $loginData = @{
        Username = "Andy"
        Password = "Password123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/authentication/login" -Method POST -Body $loginData -ContentType "application/json" -SkipCertificateCheck
    Write-Host "✅ Regular User JWT Token Generated:" -ForegroundColor Green
    Write-Host "Token: $($loginResponse.token)" -ForegroundColor Yellow
    
    # Test getting user details using user_id from token
    $userDetailsResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/authentication/user-details/2" -Method GET -SkipCertificateCheck
    Write-Host "✅ User Details Retrieved via Filtered Token Approach:" -ForegroundColor Green
    $userDetailsResponse | ConvertTo-Json -Depth 4
} catch {
    Write-Host "❌ Filtered JWT Token Test Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Role-Based Filtering
Write-Host "`n1.2. Testing Role-Based Filtering:" -ForegroundColor Cyan
try {
    # Test regular user (should be able to read but not edit)
    Write-Host "Testing regular user access..." -ForegroundColor Yellow
    $userToken = $loginResponse.token
    $headers = @{ "Authorization" = "Bearer $userToken" }
    
    # Regular user should be able to GET data
    $getResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/employee" -Method GET -Headers $headers -SkipCertificateCheck
    Write-Host "✅ Regular user can READ employee data" -ForegroundColor Green
    
    # Regular user should NOT be able to PUT data
    $putData = @{
        Empid = 1
        Ename = "Updated Name"
        Dept_ID = 1
    } | ConvertTo-Json
    
    try {
        $putResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/employee/1" -Method PUT -Body $putData -ContentType "application/json" -Headers $headers -SkipCertificateCheck
        Write-Host "❌ Regular user should NOT be able to edit data" -ForegroundColor Red
    } catch {
        Write-Host "✅ Regular user correctly blocked from editing data: $($_.Exception.Message)" -ForegroundColor Green
    }
    
    # Test admin user (should be able to read AND edit)
    Write-Host "`nTesting admin user access..." -ForegroundColor Yellow
    
    # First register an admin user
    $adminRegisterData = @{
        Username = "admin"
        Email = "admin@company.com"
        Password = "Password123"
        Role = "admin"
    } | ConvertTo-Json
    
    try {
        $adminRegisterResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/authentication/register" -Method POST -Body $adminRegisterData -ContentType "application/json" -SkipCertificateCheck
        Write-Host "✅ Admin user registered successfully" -ForegroundColor Green
    } catch {
        Write-Host "ℹ️ Admin user might already exist: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Now login as admin
    $adminLoginData = @{
        Username = "admin"
        Password = "Password123"
    } | ConvertTo-Json
    
    $adminLoginResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/authentication/login" -Method POST -Body $adminLoginData -ContentType "application/json" -SkipCertificateCheck
    $adminToken = $adminLoginResponse.token
    $adminHeaders = @{ "Authorization" = "Bearer $adminToken" }
    
    Write-Host "✅ Admin JWT Token Generated" -ForegroundColor Green
    
    # Admin should be able to GET data
    $adminGetResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/employee" -Method GET -Headers $adminHeaders -SkipCertificateCheck
    Write-Host "✅ Admin can READ employee data" -ForegroundColor Green
    
    # Admin should be able to PUT data
    try {
        $adminPutResponse = Invoke-RestMethod -Uri "https://localhost:5000/api/employee/1" -Method PUT -Body $putData -ContentType "application/json" -Headers $adminHeaders -SkipCertificateCheck
        Write-Host "✅ Admin can EDIT employee data" -ForegroundColor Green
    } catch {
        Write-Host "❌ Admin should be able to edit data: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Role-Based Filtering Test Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Department Service through API Gateway
Write-Host "`n2. Testing Department Service through API Gateway:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://localhost:5000/api/department" -Method GET -SkipCertificateCheck
    Write-Host "✅ Department Service Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Department Service Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Employee Service through API Gateway
Write-Host "`n3. Testing Employee Service through API Gateway:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://localhost:5000/api/employee" -Method GET -SkipCertificateCheck
    Write-Host "✅ Employee Service Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Employee Service Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Inter-Service Communication via Ocelot - Employee with Department
Write-Host "`n4. Testing Inter-Service Communication via Ocelot (Employee + Department):" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://localhost:5000/api/employee/with-department" -Method GET -SkipCertificateCheck
    Write-Host "✅ Employee with Department Response (via Ocelot):" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 4
} catch {
    Write-Host "❌ Inter-Service Communication via Ocelot Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test specific employee with department via Ocelot
Write-Host "`n5. Testing Specific Employee with Department via Ocelot:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://localhost:5000/api/employee/1/with-department" -Method GET -SkipCertificateCheck
    Write-Host "✅ Employee 1 with Department Response (via Ocelot):" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 4
} catch {
    Write-Host "❌ Specific Employee with Department via Ocelot Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Microservices communication test completed!" -ForegroundColor Green
Write-Host "API Gateway is running on: https://localhost:5000" -ForegroundColor Yellow
Write-Host "Authentication Service: https://localhost:7168" -ForegroundColor Yellow
Write-Host "Employee Service: https://localhost:7166" -ForegroundColor Yellow  
Write-Host "Department Service: https://localhost:7167" -ForegroundColor Yellow

Write-Host "`nPress any key to stop all services..." -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop all dotnet processes
Write-Host "`nStopping all services..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "All services stopped." -ForegroundColor Green
