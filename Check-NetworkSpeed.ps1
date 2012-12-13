$adapter = Get-WmiObject -Class Win32_NetworkAdapter -Filter DeviceID=7 -ComputerName pc-kharper

if ($adapter.Speed -ne 1000000000)
{
    Send-MailMessage -To kharper@annaly.com,vherrera@annaly.com -From kharper@annaly.com -SmtpServer nyprodmx01 -Subject "Network Adapter is not at 1 Gbps" -Body ("Current speed is " + ($adapter.Speed / 1000000) + "Mbps")
}
