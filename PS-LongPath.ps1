# Define the root directory to scan
$RootPath = "C:\YourFileServerShare" # Change this to your file server path
$MaxPathLength = 260  # Set the length threshold
$OutputFile = "C:\long_paths.csv" # Change this to your desired output file

# Ensure PowerShell can handle long paths (requires Windows 10+ and proper Group Policy settings)
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Force

# Initialize an array to store long file paths
$LongPaths = @()

# Recursively get all files and check their full path length
Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $FullPath = $_.FullName
    if ($FullPath.Length -gt $MaxPathLength) {
        $LongPaths += [PSCustomObject]@{
            Path = $FullPath
            Length = $FullPath.Length
        }
    }
}

# Export the results to a CSV file
if ($LongPaths.Count -gt 0) {
    $LongPaths | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "Long file paths have been saved to $OutputFile"
} else {
    Write-Host "No long file paths found."
}
