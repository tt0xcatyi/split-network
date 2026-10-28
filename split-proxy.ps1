param([switch]$Off)
$k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$c = "$k\Connections"
$b = (Get-ItemProperty $c).DefaultConnectionSettings
$b[4] = [byte](($b[4] + 1) % 256)
if ($Off) {
  $b[8] = 9; Set-ItemProperty $k ProxyEnable 0
} else {
  $b[8] = 3; Set-ItemProperty $k ProxyEnable 1
}
Set-ItemProperty $c DefaultConnectionSettings $b
$sig = '[DllImport("wininet.dll")] public static extern bool InternetSetOption(IntPtr h, int o, IntPtr b, int l);'
$w = Add-Type -MemberDefinition $sig -Name WI -Namespace NS -PassThru
[void]$w::InternetSetOption(0, 39, 0, 0); [void]$w::InternetSetOption(0, 37, 0, 0)
