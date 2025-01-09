# Ensure the script is running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator. Please restart PowerShell as Administrator." -ErrorAction Stop
}

# Define the Registry Path for WindowsUpdate
$RegPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"

# Check if the Registry Path exists
if (Test-Path $RegPath) {
    Write-Host "Fetching WindowsUpdate registry settings..." -ForegroundColor Cyan

    try {
        # Retrieve ProductVersion
        $ProductVersion = (Get-ItemProperty -Path $RegPath -Name "ProductVersion" -ErrorAction SilentlyContinue).ProductVersion
        if ($ProductVersion) {
            Write-Host "ProductVersion: $ProductVersion" -ForegroundColor Green
        } else {
            Write-Host "ProductVersion: Not Found" -ForegroundColor Yellow
        }

        # Retrieve TargetReleaseVersionInfo
        $TargetReleaseVersionInfo = (Get-ItemProperty -Path $RegPath -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue).TargetReleaseVersionInfo
        if ($TargetReleaseVersionInfo) {
            Write-Host "TargetReleaseVersionInfo: $TargetReleaseVersionInfo" -ForegroundColor Green
        } else {
            Write-Host "TargetReleaseVersionInfo: Not Found" -ForegroundColor Yellow
        }

        # Retrieve TargetReleaseVersion
        $TargetReleaseVersion = (Get-ItemProperty -Path $RegPath -Name "TargetReleaseVersion" -ErrorAction SilentlyContinue).TargetReleaseVersion
        if ($TargetReleaseVersion -ne $null) {
            Write-Host "TargetReleaseVersion: $TargetReleaseVersion" -ForegroundColor Green
        } else {
            Write-Host "TargetReleaseVersion: Not Found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Error "An error occurred while retrieving registry values: $_"
    }
} else {
    Write-Host "Registry path '$RegPath' does not exist. No settings to display." -ForegroundColor Red
}
