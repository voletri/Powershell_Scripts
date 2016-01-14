$serverlist="USLIAPADFS3","USLIAPADFS4","USILAPADFS3","USILAPADFS4"
$serverlist|%{


Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName="AD FS/Admin";id=111} -MaxEvents 1|select ActivityId,MachineName,@{l="Msg";e={$([String]$_.Message)}},UserId,TimeCreated

}|export-csv C:\Temp\log.csv -NoTypeInformation



<#
$serverlist="USLIAPADFS3","USLIAPADFS4","USILAPADFS3","USILAPADFS4"

#$a=Get-WinEvent -ComputerName $Server -FilterHashtable @{LogName="AD FS/Admin";id=111}|select -First 1

#$c=$a.activityId

$ActivityID="9f9ab388-51a1-4710-83a3-e766eff7b309"

$serverlist|%{
#Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName="AD FS/Admin";id=111}|where{$_.ActivityId -eq $ActivityID}|select ActivityId,MachineName,@{l="Msg";e={$([String]$_.Message)}},UserId,TimeCreated

Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName="AD FS/Admin";id=111}|select ActivityId,MachineName,@{l="Msg";e={$([String]$_.Message)}},UserId,TimeCreated

}|export-csv C:\Temp\log.csv -NoTypeInformation

Get-WinEvent -ComputerName $server -FilterHashtable @{LogName="AD FS/Admin";id=111;}|where{$_.ActivityId -eq $ActivityID}|select ActivityId,MachineName,[String]Message,UserId,TimeCreated


#>
