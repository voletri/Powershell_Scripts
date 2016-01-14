Get-Help get-EventLog -Examples


$dc1="inhydc03"

get-EventLog -LogName Security -Newest 10 -Message "*$user*" -ComputerName $dc1| Where-Object { $_.EventID -eq 4771 } | select properties | Export-Csv C:\Temp\4771_new.csv -NoTypeInformation


Get-WinEvent -ComputerName $dc1 -MaxEvents 10 -FilterHashtable @{LogName='Security';Id=4771;StartTime = $date;}|Select-Object -Property Properties -First 50|Export-Csv C:\Temp\4771_new.csv -NoTypeInformation



get-EventLog -LogName Security -Message "*$user*" -ComputerName $dc1


| Where-Object { $_.EventID -eq 4771 }


    $dc1="inhydc01"
    $date = (Get-Date).AddDays(-2)
    [object[]]$details=Get-WinEvent -ComputerName $dc1 -FilterHashtable @{LogName='Security';Id=4771;StartTime = $date;}|Select-Object -Property TimeCreated,Properties

   # get-help Get-WinEvent -Examples

$date = (Get-Date).AddDays(-1)

[object[]]$dc_events=Get-WinEvent -ComputerName "inhydc03" -FilterHashtable @{LogName='Security';Id=4771;StartTime =$date} -MaxEvents 1000|Select-Object -Property Properties,message

$user="angma02"

$user_events=$dc_events|where{$_.message -like "*$user*"}
###########
$userDetails=




Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {badPwdCount -gt 80} -Properties SamAccountName,AccountLockoutTime,badPasswordTime,badPwdCount,LastBadPasswordAttempt,lastLogon,LastLogonDate,lastLogonTimestamp,LockedOut,lockoutTime -ResultSetSize $null -ResultPageSize 1000|where{(((Get-Date)-($_.LastBadPasswordAttempt)).Days) -le 2}|select SamAccountName,badPwdCount,AccountLockoutTime,LockedOut,@{Expression={[datetime]::fromfiletime($_.lockoutTime )};Label="lockoutTime "},LastBadPasswordAttempt,LastLogonDate,@{Expression={$dc1};Label="DomainController"}


$a=Get-ADUser salmo07 -properties LastBadPasswordAttempt|select LastBadPasswordAttempt


where{(((Get-Data.LastBadPasswordAttempt)).Days) -le 2}


################################
$userDetails




Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {badPwdCount -gt 80} -Properties SamAccountName,AccountLockoutTime,badPasswordTime,badPwdCount,LastBadPasswordAttempt,lastLogon,LastLogonDate,lastLogonTimestamp,LockedOut,lockoutTime -ResultSetSize $null -ResultPageSize 1000|where{(((Get-Date)-($_.LastBadPasswordAttempt)).Days) -le 2}|select SamAccountName,badPwdCount,AccountLockoutTime,LockedOut,@{Expression={[datetime]::fromfiletime($_.lockoutTime )};Label="lockoutTime "},LastBadPasswordAttempt,LastLogonDate,@{Expression={$dc1};Label="DomainController"}


$a=Get-ADUser salmo07 -properties LastBadPasswordAttempt|select LastBadPasswordAttempt


where{(((Get-Data.LastBadPasswordAttempt)).Days) -le 2}|
##################