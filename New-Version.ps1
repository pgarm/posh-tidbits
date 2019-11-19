function New-Version {
    param (
        [int]$Major=0,
        [int]$Minor=1,
        [datetime]$Base = (Get-Date "01 April 2018"),
        [switch]$Revision
    )
    if ($Revision) {
        return "$Major.$Minor." + [math]::round((New-TimeSpan -Start $Base.Date -End (Get-Date)).TotalDays,3)
    } else {
        return "$Major.$Minor." + (New-TimeSpan -Start $Base.Date -End (Get-Date)).Days
    }
}