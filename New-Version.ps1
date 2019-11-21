function New-Version {
    param (
        [Parameter(Position=0)][int]$Major=0,
        [Parameter(Position=1)][int]$Minor=1,
        [datetime]$Base = (Get-Date "01 April 2018"),
        [datetime]$Point = (Get-Date),
        [switch]$AsText,
        [int]$RevDigits=3
    )
    
    $Timestamp = New-TimeSpan -Start $Base.Date -End $Point
    [string]$ver = "$Major.$Minor.$($Timestamp.Days).$([int](($Timestamp.TotalDays - $Timestamp.Days)*([math]::pow(10,$RevDigits))))"

    if ($AsText) {return $ver} else {return [version]$ver}
}