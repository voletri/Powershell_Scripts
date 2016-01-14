
$servers = Get-ADComputer -Filter *  -Properties *  | ? {$_.OperatingSystem -like "*2000*"}

foreach ($server in $servers)

{

$Checktime = (get-date).adddays(-30)

if ((($server.lastlogondate).date - $checktime.date) -le 0)

{
#$ServerLastLogon = "False"
}

Else
{
$ServerLastLogon = "True"
$ping = Test-Connection -ComputerName $Server.name -count 1  -Quiet -ErrorAction  SilentlyContinue
if ($ping -eq "True")

{
$pingable = "True"

$NIC = Get-WmiObject -Class win32_networkadapterconfiguration -ComputerName $Server.Name | ? {$_.IPaddress -ne $null -and $_.IPEnabled -eq $true}



$array = @()

$Properties = @{"Server Name"=$server.name;"Last logon within 30 days"=$serverlastlogon;Pingable=$pingable;Enabled=$server.enabled;"Operating System"=$server.operatingsystem;"IP Address"=$Nic.ipaddress -join ', '}

$Newobject = New-Object  PSObject -Property  $Properties

$Array +=$Newobject

 


} 
}

$path = "d:\test.csv"

$array | Select-Object "Server Name","Last Logon within 30 days",Pingable,"Operating System",Enabled,"IP Address" | export-csv $path -Append


}