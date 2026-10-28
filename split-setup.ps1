$log = Join-Path $PSScriptRoot 'split.log'
Start-Transcript $log -Force | Out-Null
$w = Get-NetAdapter | Where-Object InterfaceDescription -like '*Wireless*' | Select-Object -First 1
$e = Get-NetAdapter | Where-Object InterfaceDescription -like '*Ethernet*' | Select-Object -First 1
"WIFI=$($w.Name) idx=$($w.ifIndex)  ETH=$($e.Name) idx=$($e.ifIndex)"
Set-NetIPInterface -InterfaceIndex $w.ifIndex -AddressFamily IPv4 -InterfaceMetric 10
Enable-NetAdapter -Name $e.Name -Confirm:$false
Set-NetIPInterface -InterfaceIndex $e.ifIndex -AddressFamily IPv4 -InterfaceMetric 60 -ErrorAction SilentlyContinue
$gw = $null
for ($i = 0; $i -lt 45; $i++) {
  Start-Sleep 1
  $gw = (Get-NetRoute -InterfaceIndex $e.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
  if ($gw) { break }
}
Set-NetIPInterface -InterfaceIndex $e.ifIndex -AddressFamily IPv4 -InterfaceMetric 60
"ETH GW=$gw"
if (-not $gw) { 'NO ETH GATEWAY - aborting'; Stop-Transcript | Out-Null; exit 1 }
foreach ($p in '10.0.0.0/8','172.16.0.0/12','192.168.0.0/16') {
  Get-NetRoute -DestinationPrefix $p -InterfaceIndex $e.ifIndex -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue
  New-NetRoute -DestinationPrefix $p -InterfaceIndex $e.ifIndex -NextHop $gw -RouteMetric 1 | Out-Null
  "ROUTE $p via $gw"
}
"ETH IP=" + ((Get-NetIPAddress -InterfaceIndex $e.ifIndex -AddressFamily IPv4).IPAddress -join ',')
"ETH DNS=" + ((Get-DnsClientServerAddress -InterfaceIndex $e.ifIndex -AddressFamily IPv4).ServerAddresses -join ',')
"ETH SUFFIX=" + (Get-DnsClient -InterfaceIndex $e.ifIndex).ConnectionSpecificSuffix
'DONE'
Stop-Transcript | Out-Null

