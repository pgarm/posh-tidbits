$ports = @(53,389,135)
$servers = @('10.236.0.65','10.236.0.67')
$out = @()

foreach ($server in $servers) {
    $outsrv = New-Object -TypeName psobject
    $outsrv | Add-Member -NotePropertyName Server -NotePropertyValue $server
    foreach ($port in $ports) {
        $outsrv | Add-Member -NotePropertyName $port -NotePropertyValue (Test-NetConnection -ComputerName $server -Port $port).TcpTestSucceeded
    }
    $out += $outsrv; rv outsrv
}
$out; rv out
