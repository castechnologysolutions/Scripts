function Check-PendingReboot {
    $rebootRequired = $false
    
    # Check Windows Update Pending Reboot
    $windowsUpdate = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -ErrorAction SilentlyContinue
    if ($windowsUpdate -and $windowsUpdate.RebootRequired) {
        Write-Output "Windows Update: A reboot is required."
        $rebootRequired = $true
    }
    
    # Check Component-Based Servicing (CBS) Pending Reboot
    $cbsReboot = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
    if ($cbsReboot) {
        Write-Output "Component-Based Servicing (CBS): A reboot is required."
        $rebootRequired = $true
    }
    
    # Check PendingFileRenameOperations
    $pendingFileRename = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue
    if ($pendingFileRename -and $pendingFileRename.PendingFileRenameOperations) {
        Write-Output "Pending File Rename Operations: A reboot is required."
        $rebootRequired = $true
    }
    
    # Check Windows Installer (MSI) Pending Reboot
    $msiReboot = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer" -Name "InProgress" -ErrorAction SilentlyContinue
    if ($msiReboot) {
        Write-Output "Windows Installer: A reboot is required."
        $rebootRequired = $true
    }
    
    # Check Cluster Node Pending Reboot (if applicable)
    if (Test-Path "HKLM:\Cluster\") {
        $clusterReboot = Get-ItemProperty -Path "HKLM:\Cluster\" -Name "RestartPending" -ErrorAction SilentlyContinue
        if ($clusterReboot) {
            Write-Output "Cluster Node: A reboot is required."
            $rebootRequired = $true
        }
    }
    
    if (-not $rebootRequired) {
        Write-Output "No pending reboot detected."
    }
}

# Execute the function
Check-PendingReboot
