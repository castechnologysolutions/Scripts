### 📜 **PowerShell Script to Create WindowsUpdate Registry Keys for Windows 11 24H2**

##This script automates the process of creating the necessary registry keys and values to ensure Windows targets **Windows 11 24H2** updates.

##---

### ⚠️ **Prerequisites:**
##- Run the script as an **Administrator**.
##- Make sure to **back up your registry** before proceeding.

##---

### 🚀 **PowerShell Script**

#```powershell
# Ensure the script is running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Please restart PowerShell as Administrator." -ErrorAction Stop
}

# Define the Registry Path for WindowsUpdate
$RegPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"

# Create the WindowsUpdate Key if it doesn't exist
try {
    Write-Host "Checking if WindowsUpdate registry key exists..." -ForegroundColor Cyan
    
    if (-not (Test-Path $RegPath)) {
        Write-Host "WindowsUpdate key not found. Creating the key..." -ForegroundColor Yellow
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name "WindowsUpdate" -Force | Out-Null
    } else {
        Write-Host "WindowsUpdate key already exists." -ForegroundColor Green
    }

    # Create ProductVersion (String Value)
    Write-Host "Setting 'ProductVersion' to 'Windows 11'..." -ForegroundColor Cyan
    Set-ItemProperty -Path $RegPath -Name "ProductVersion" -Value "Windows 11" -Type String

    # Create TargetReleaseVersionInfo (String Value)
    Write-Host "Setting 'TargetReleaseVersionInfo' to '24H2'..." -ForegroundColor Cyan
    Set-ItemProperty -Path $RegPath -Name "TargetReleaseVersionInfo" -Value "24H2" -Type String

    # Create TargetReleaseVersion (DWORD)
    Write-Host "Setting 'TargetReleaseVersion' to '1'..." -ForegroundColor Cyan
    Set-ItemProperty -Path $RegPath -Name "TargetReleaseVersion" -Value 1 -Type DWord

    Write-Host "Registry keys and values have been successfully configured!" -ForegroundColor Green
    
} catch {
    Write-Error "An error occurred: $_"
}
#```

#---

## 🛠️ **What the Script Does:**

#1. **Registry Key Creation:**  
#   - Checks if the `WindowsUpdate` key exists under `HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows`.  
#   - Creates it if it doesn’t exist.
#
#2. **Add Registry Values:**  
#   - **`ProductVersion`** (String): Set to `Windows 11`.  
#   - **`TargetReleaseVersionInfo`** (String): Set to `24H2`.  
#   - **`TargetReleaseVersion`** (DWORD): Set to `1`.

#3. **Validation and Error Handling:**  
#   - Ensures each step completes successfully and provides feedback.
#
#---

## 🚀 **How to Run the Script:**

#1. Open **Notepad** or any text editor.  
#2. Copy and paste the script.  
#3. Save the file as `ConfigureWindowsUpdate.ps1`.  
#4. Open **PowerShell as Administrator**.  
#5. Navigate to the folder where the script is saved.  
#6. Run the script:  
#   ```powershell
#   .\ConfigureWindowsUpdate.ps1
#   ```
#
#---
#
## ✅ **Verification:**
#
#1. Open **Registry Editor (regedit.exe)**.  
#2. Navigate to:  
#   ```
#   HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate
#   ```
#3. Confirm the following keys exist:
#   - **ProductVersion** → `Windows 11`
#   - **TargetReleaseVersionInfo** → `24H2`
#   - **TargetReleaseVersion** → `1`
#
#4. Restart your computer and check **Windows Update**.
#
#---
#
#Let me know if you face any issues! 😊
