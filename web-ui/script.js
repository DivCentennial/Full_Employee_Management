        // Configuration
        const API_BASE_URL = 'https://localhost:5000';
        const AUTH_BASE_URL = 'https://localhost:7168';

let currentToken = localStorage.getItem('authToken');
let currentUser = localStorage.getItem('currentUser');

// Initialize UI
document.addEventListener('DOMContentLoaded', function() {
    updateAuthStatus();
});

// Authentication Functions
async function register() {
    const username = document.getElementById('regUsername').value;
    const email = document.getElementById('regEmail').value;
    const password = document.getElementById('regPassword').value;
    const role = document.getElementById('regRole').value;

    if (!username || !email || !password) {
        showResult('authResult', 'Please fill in all fields', 'error');
        return;
    }

            // Use HTTPS only (no HTTP fallback)
            let response;
            try {
                response = await fetch(`${AUTH_BASE_URL}/api/authentication/register`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ username, email, password, role })
                });
            } catch (error) {
                showResult('authResult', `❌ Connection Error: ${error.message}\n\nTry opening Chrome with disabled security for testing.`, 'error');
                return;
            }

    try {
        const result = await response.json();
        
        if (response.ok) {
            showResult('authResult', `✅ Registration successful!\n${JSON.stringify(result, null, 2)}`, 'success');
            clearRegistrationForm();
        } else {
            showResult('authResult', `❌ Registration failed:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (parseError) {
        showResult('authResult', `❌ Response Error: ${parseError.message}`, 'error');
    }
}

async function login() {
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;

    if (!username || !password) {
        showResult('authResult', 'Please enter username and password', 'error');
        return;
    }

            // Use HTTPS only (no HTTP fallback)
            let response;
            try {
                response = await fetch(`${AUTH_BASE_URL}/api/authentication/login`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ username, password })
                });
            } catch (error) {
                showResult('authResult', `❌ Connection Error: ${error.message}\n\nTry opening Chrome with disabled security for testing.`, 'error');
                return;
            }

    try {
        const result = await response.json();
        
        if (response.ok) {
            currentToken = result.token;
            currentUser = result.username;
            localStorage.setItem('authToken', currentToken);
            localStorage.setItem('currentUser', currentUser);
            
            showResult('authResult', `✅ Login successful!\nWelcome, ${result.username}!\nExists in JSON: ${result.exists}`, 'success');
            showToken(result.token);
            updateAuthStatus();
            clearLoginForm();
        } else {
            showResult('authResult', `❌ Login failed:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (parseError) {
        showResult('authResult', `❌ Response Error: ${parseError.message}\n\nSince Postman works, this is likely a CORS issue.\nTry opening Chrome with disabled security.`, 'error');
    }
}

function logout() {
    currentToken = null;
    currentUser = null;
    localStorage.removeItem('authToken');
    localStorage.removeItem('currentUser');
    
    showResult('authResult', '👋 Logged out successfully', 'info');
    hideToken();
    updateAuthStatus();
}

// Employee Functions
async function getEmployees() {
    if (!checkAuth()) return;

    try {
        const response = await fetch(`${API_BASE_URL}/api/employee`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('employeeResult', `✅ Employees retrieved successfully!\n${JSON.stringify(result, null, 2)}`, 'success');
        } else {
            showResult('employeeResult', `❌ Failed to get employees:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('employeeResult', `❌ Error: ${error.message}`, 'error');
    }
}

async function getEmployeesWithDepartment() {
    if (!checkAuth()) return;

    try {
        const response = await fetch(`${API_BASE_URL}/api/employee/with-dept-simple`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('employeeResult', `✅ Employees with Department retrieved successfully!\n${JSON.stringify(result, null, 2)}`, 'success');
        } else {
            showResult('employeeResult', `❌ Failed to get employees with department:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('employeeResult', `❌ Error: ${error.message}`, 'error');
    }
}

async function getEmployeeById() {
    if (!checkAuth()) return;

    const empId = document.getElementById('empId').value;
    if (!empId) {
        showResult('employeeResult', 'Please enter an employee ID', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/api/employee/${empId}`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('employeeResult', `✅ Employee retrieved successfully!\n${JSON.stringify(result, null, 2)}`, 'success');
        } else {
            showResult('employeeResult', `❌ Failed to get employee:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('employeeResult', `❌ Error: ${error.message}`, 'error');
    }
}

// Department Functions
async function getDepartments() {
    if (!checkAuth()) return;

    try {
        const response = await fetch(`${API_BASE_URL}/api/department`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('departmentResult', `✅ Departments retrieved successfully!\n${JSON.stringify(result, null, 2)}`, 'success');
        } else {
            showResult('departmentResult', `❌ Failed to get departments:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('departmentResult', `❌ Error: ${error.message}`, 'error');
    }
}

async function getDepartmentById() {
    if (!checkAuth()) return;

    const deptId = document.getElementById('deptId').value;
    if (!deptId) {
        showResult('departmentResult', 'Please enter a department ID', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/api/department/${deptId}`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('departmentResult', `✅ Department retrieved successfully!\n${JSON.stringify(result, null, 2)}`, 'success');
        } else {
            showResult('departmentResult', `❌ Failed to get department:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('departmentResult', `❌ Error: ${error.message}`, 'error');
    }
}

// Utility Functions
function checkAuth() {
    if (!currentToken) {
        showResult('employeeResult', '❌ Please login first!', 'error');
        showResult('departmentResult', '❌ Please login first!', 'error');
        return false;
    }
    return true;
}

function showResult(elementId, message, type) {
    const element = document.getElementById(elementId);
    element.textContent = message;
    element.className = `result ${type}`;
    element.style.display = 'block';
}

function showToken(token) {
    const tokenDisplay = document.getElementById('tokenDisplay');
    tokenDisplay.textContent = `JWT Token: ${token}`;
    tokenDisplay.style.display = 'block';
}

function hideToken() {
    const tokenDisplay = document.getElementById('tokenDisplay');
    tokenDisplay.style.display = 'none';
}

function updateAuthStatus() {
    const statusElement = document.getElementById('authStatus');
    if (currentUser && currentToken) {
        statusElement.textContent = `Logged in as: ${currentUser}`;
        statusElement.className = 'status logged-in';
    } else {
        statusElement.textContent = 'Not Logged In';
        statusElement.className = 'status logged-out';
    }
}

function clearRegistrationForm() {
    document.getElementById('regUsername').value = '';
    document.getElementById('regEmail').value = '';
    document.getElementById('regPassword').value = '';
    document.getElementById('regRole').value = 'user';
}

function clearLoginForm() {
    document.getElementById('loginUsername').value = '';
    document.getElementById('loginPassword').value = '';
}

// File Upload Functions
async function uploadJson() {
    if (!checkAuth()) return;
    
    const fileInput = document.getElementById('jsonFile');
    if (!fileInput.files.length) {
        showResult('uploadResult', 'Please select a JSON file', 'error');
        return;
    }

    const formData = new FormData();
    formData.append("file", fileInput.files[0]);

    try {
        const response = await fetch(`${AUTH_BASE_URL}/api/authentication/bulk-register`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${currentToken}`
            },
            body: formData
        });

        const result = await response.json();
        
        if (response.ok) {
            let message = `✅ ${result.message}\n\n`;
            message += `Total Processed: ${result.totalProcessed}\n`;
            message += `Success: ${result.successCount}\n`;
            message += `Errors: ${result.errorCount}\n\n`;
            message += `Results:\n${JSON.stringify(result.results, null, 2)}`;
            
            showResult('uploadResult', message, 'success');
        } else {
            showResult('uploadResult', `❌ Upload failed:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('uploadResult', `❌ Error: ${error.message}`, 'error');
    }
}

async function showJsonFormat() {
    try {
        const response = await fetch(`${AUTH_BASE_URL}/api/authentication/validate-json`, {
            headers: {
                'Authorization': `Bearer ${currentToken}`
            }
        });

        const result = await response.json();
        
        if (response.ok) {
            showResult('uploadResult', `📋 Expected JSON Format:\n${JSON.stringify(result, null, 2)}`, 'info');
        } else {
            showResult('uploadResult', `❌ Failed to get format:\n${JSON.stringify(result, null, 2)}`, 'error');
        }
    } catch (error) {
        showResult('uploadResult', `❌ Error: ${error.message}`, 'error');
    }
}
