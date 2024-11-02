# Install MSOnline module if not installed
if (-not (Get-Module -ListAvailable -Name MSOnline)) {
    Install-Module -Name MSOnline -Force
}

# Import the MSOnline module
Import-Module MSOnline

# Connect to Office 365
$O365Creds = Get-Credential
Connect-MsolService -Credential $O365Creds

# Get all users in the tenant
$allUsers = Get-MsolUser -All

# Filter users without licenses
$unlicensedUsers = $allUsers | Where-Object { $_.IsLicensed -eq $false }

# Disable each unlicensed user
foreach ($user in $unlicensedUsers) {
    # Disable the user
    Set-MsolUser -UserPrincipalName $user.UserPrincipalName -BlockCredential $true
    Write-Output "Disabled user: $($user.UserPrincipalName)"
}

# Disconnect from the service
Disconnect-MsolService
