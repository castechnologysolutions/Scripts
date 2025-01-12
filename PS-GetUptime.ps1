#(get-computerinfo).osuptime

Function Get-Uptime
{
    param
    (
        [Parameter()]
        [switch]
        $Since
    )

    BEGIN
    {
        $LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem -Property LastBootUpTime).LastBootUpTime
    }

    PROCESS
    {
        if ($Since -eq $true)
        {
            return $LastBootUpTime
        }
        else
        {
            return (Get-Date) - $LastBootUpTime
        }
    }

}
