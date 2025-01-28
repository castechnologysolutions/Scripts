<#
.SYNOPSIS
    Resets and repairs Windows Update components on Windows, plus runs DISM & SFC.
 
.DESCRIPTION
    1) Stops Windows Update services.
    2) Renames the SoftwareDistribution and Catroot2 folders.
    3) Re-registers Windows Update DLLs.
    4) Runs DISM RestoreHealth and SFC /scannow to repair any system file corruption.
    5) Restarts relevant services.
 
.NOTES
#>
 
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$ForceRun
)
 
function Reset-WindowsUpdate {
    [CmdletBinding()]
    param()
 
    Write-Host "========== Windows Update Reset Starting =========="
 
    # Verify script is running as Administrator
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as Administrator. Exiting."
        return
    }
 
    # Services to stop/start
    $services = @(
        "wuauserv",    # Windows Update
        "BITS",        # Background Intelligent Transfer Service
        "cryptSvc",    # Cryptographic Services
        "msiserver"    # Windows Installer
    )
 
    #------------------------#
    # STEP 1: Stop Services  #
    #------------------------#
    Write-Host "Stopping services..."
    foreach ($service in $services) {
        Write-Host "  Stopping $service ..."
        Stop-Service $service -Force -ErrorAction SilentlyContinue
    }
 
    # Give it a moment to ensure services have fully stopped
    Start-Sleep -Seconds 5
 
    #-------------------------------------------------------------#
    # STEP 2: Rename or Delete the SoftwareDistribution/Catroot2  #
    #-------------------------------------------------------------#
 
    $sdPath       = Join-Path $env:SystemRoot "SoftwareDistribution"
    $catroot2Path = Join-Path $env:SystemRoot "System32\Catroot2"
 
    Write-Host "Renaming (or deleting) SoftwareDistribution and Catroot2 folders..."
 
    # SoftwareDistribution
    if (Test-Path $sdPath) {
        try {
            Rename-Item -Path $sdPath -NewName ("SoftwareDistribution.old_{0}" -f (Get-Date -Format "yyyyMMddHHmmss")) -ErrorAction Stop
            Write-Host "  Renamed SoftwareDistribution."
        } catch {
            Write-Warning "  Could not rename SoftwareDistribution. Attempting to remove..."
            Remove-Item -Path $sdPath -Recurse -Force -ErrorAction Continue
        }
    } else {
        Write-Host "  SoftwareDistribution folder not found or already removed."
    }
 
    # Catroot2
    if (Test-Path $catroot2Path) {
        try {
            Rename-Item -Path $catroot2Path -NewName ("Catroot2.old_{0}" -f (Get-Date -Format "yyyyMMddHHmmss")) -ErrorAction Stop
            Write-Host "  Renamed Catroot2 folder."
        } catch {
            Write-Warning "  Could not rename Catroot2. Attempting to remove..."
            Remove-Item -Path $catroot2Path -Recurse -Force -ErrorAction Continue
        }
    } else {
        Write-Host "  Catroot2 folder not found or already removed."
    }
 
    #------------------------------#
    # STEP 3: Re-register DLL/OCX  #
    #------------------------------#
 
    Write-Host "Re-registering core Windows Update DLLs..."
    $dlls = @(
        "atl.dll",
        "urlmon.dll",
        "mshtml.dll",
        "shdocvw.dll",
        "browseui.dll",
        "jscript.dll",
        "vbscript.dll",
        "scrrun.dll",
        "msxml.dll",
        "msxml2.dll",
        "msxml3.dll",
        "msxml6.dll",
        "actxprxy.dll",
        "softpub.dll",
        "wintrust.dll",
        "dssenh.dll",
        "rsaenh.dll",
        "gpkcsp.dll",
        "sccbase.dll",
        "slbcsp.dll",
        "cryptdlg.dll",
        "oleaut32.dll",
        "ole32.dll",
        "shell32.dll",
        "initpki.dll",
        "wuapi.dll",
        "wuaueng.dll",
        "wuaueng1.dll",
        "wucltui.dll",
        "wups.dll",
        "wups2.dll",
        "wuweb.dll",
        "qmgr.dll",
        "qmgrprxy.dll",
        "wucltux.dll",
        "muweb.dll",
        "wuwebv.dll"
    )
 
    foreach ($dll in $dlls) {
        $fullPath = Join-Path $env:SystemRoot "System32\$dll"
        if (Test-Path $fullPath) {
            try {
                regsvr32.exe /s $fullPath
                Write-Host "  Registered $dll"
            }
            catch {
                Write-Warning "  Error registering $dll $($_.Exception.Message)"
            }
        } else {
            Write-Warning "  $dll not found in System32, skipping."
        }
    }
 
    Write-Host "========== Windows Update Reset Completed =========="
}
 
function Repair-WindowsSystem {
    [CmdletBinding()]
    param()
 
    Write-Host "`n========== System File & Image Repair Starting =========="
    # Check if Administrator
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This function must be run as Administrator. Exiting."
        return
    }
 
    #-----------------------------------------------------#
    # STEP 4: DISM /Online /Cleanup-Image /RestoreHealth  #
    #-----------------------------------------------------#
    try {
        Write-Host "Running DISM ScanHealth..."
        dism.exe /online /cleanup-image /scanhealth
        Write-Host "Running DISM RestoreHealth..."
        dism.exe /online /cleanup-image /restorehealth
        Write-Host "  DISM steps completed."
    } catch {
        Write-Warning "  DISM encountered an error: $($_.Exception.Message)"
    }
 
    #-------------------------------------------#
    # STEP 5: SFC (System File Checker) /scannow#
    #-------------------------------------------#
    try {
        Write-Host "Running SFC /scannow..."
        sfc.exe /scannow
        Write-Host "  SFC scan completed."
    } catch {
        Write-Warning "  SFC encountered an error: $($_.Exception.Message)"
    }
 
    Write-Host "========== System File & Image Repair Completed =========="
}
 
# Main Script Execution
if ($ForceRun -or $PSCmdlet.ShouldProcess("Aggressive Windows Update + Repairs")) {
    # 1) Reset Windows Update
    Reset-WindowsUpdate
 
    # 2) Run DISM & SFC
    Repair-WindowsSystem
 
    # 3) Restart Services
    Write-Host "`nStarting Windows Update-related services..."
 
    $services = @(
        "wuauserv",
        "BITS",
        "cryptSvc",
        "msiserver"
    )
    foreach ($service in $services) {
        Write-Host "  Starting $service ..."
        Set-Service -Name $service -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service $service -ErrorAction SilentlyContinue
    }
 
    Write-Host "`nAll done. Please reboot your system if advised."
} else {
    Write-Host "Use -ForceRun to execute or run with -WhatIf to see changes. No action taken."
}
