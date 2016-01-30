if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    break
}

(route print | Select-String -Pattern "10.242.240.0") -match "10.242.242.\d\d\d"
$vpnIp = $Matches[0].Trim()

route add 104.130.175.250 mask 255.255.255.255 $vpnIp # rsva-core01
route add 104.130.163.186 mask 255.255.255.255 $vpnIp # rsva-core02
route add 104.130.3.243 mask 255.255.255.255 $vpnIp # rsva-core03
route add 104.130.5.22 mask 255.255.255.255 $vpnIp # rsva-core04
route add 162.242.238.34 mask 255.255.255.255 $vpnIp # rsva-core05
route add 172.99.68.120 mask 255.255.255.255 $vpnIp # rsva-deb01
route add 104.239.249.109 mask 255.255.255.255 $vpnIp # rsva-deb02
