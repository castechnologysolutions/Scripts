#(get-computerinfo).osuptime

# Script to get Windows computer uptime and last reboot time

# Function to calculate the system uptime
Function Get-SystemUptime {
    # Get the current date and time
    $currentDate = Get-Date

    # Get the last boot-up time using WMI (Win32_OperatingSystem)
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $lastBootUpTime = $os.LastBootUpTime

    # Convert the last boot-up time to a readable format
    $lastBootDateTime = [Management.ManagementDateTimeConverter]::ToDateTime($lastBootUpTime)

    # Calculate uptime
    $uptime = $currentDate - $lastBootDateTime

    # Return a custom object with the results
    [PSCustomObject]@{
        "Current Time"      = $currentDate
        "Last Reboot Time" = $lastBootDateTime
        "Uptime"           = $uptime.Days.ToString() + " days, " + $uptime.Hours.ToString() + " hours, " + $uptime.Minutes.ToString() + " minutes"
    }
}

# Run the function and output the results
Get-SystemUptime
