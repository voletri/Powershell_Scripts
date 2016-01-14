


$ServerName="inhydc01"
$days=-3
Get-WinEvent -ComputerName $ServerName -FilterHashtable @{LogName="Application Log";Id=1644;StartTime=(((Get-Date).addDays(-1)).date);EndTime=Get-Date; }|select MachineName,Message,Id,UserId,TimeCreated|Export-Csv C:\Temp\1644_$ServerName.csv -NoTypeInformation