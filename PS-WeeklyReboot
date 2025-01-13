# Define the schedule parameters
$TaskName = "WeeklyReboot"
$Description = "Reboots the computer once a week."
$ScheduleTime = "03:00AM"  # Adjust to your desired time
$DaysOfWeek = @(1)  # 0 = Sunday, 1 = Monday, ..., 6 = Saturday

# Define the action (reboot command)
$Action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 0"

# Define the schedule (weekly on specified days)
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek -At $ScheduleTime

# Set the task principal (runs with highest privileges)
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register the scheduled task
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Description $Description

Write-Host "Weekly reboot task created successfully."
