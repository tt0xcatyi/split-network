$w = Get-NetAdapter | Where-Object InterfaceDescription -like '*Wireless*' | Select-Object -First 1
$e = Get-NetAdapter | Where-Object InterfaceDescription -like '*Ethernet*' | Select-Object -First 1
foreach ($p in '10.0.0.0/8','172.16.0.0/12','192.168.0.0/16') {
  Get-NetRoute -DestinationPrefix $p -ErrorAction SilentlyContinue | Where-Object NextHop -ne '0.0.0.0' | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue
  Get-NetRoute -DestinationPrefix $p -PolicyStore PersistentStore -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue
}
Set-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily IPv4 -AutomaticMetric Enabled
Set-NetIPInterface -InterfaceIndex $e.ifIndex -AddressFamily IPv4 -AutomaticMetric Enabled
Disable-NetAdapter -Name $e.Name -Confirm:$false

& "$PSScriptRoot\split-proxy.ps1" -Off

