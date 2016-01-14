Get-ADComputer -Filter * -Properties DistinguishedName, DNSHostName, Enabled ,Name ,OperatingSystem| select-object DistinguishedName, DNSHostName, Enabled ,Name ,OperatingSystem | export-csv C:\Users\salmo07\Desktop\Computer.csv -notypeinformation
 
Get-ADComputer –filter * -Properties * | Select DistinguishedName, DNSHostName,Name ,OperatingSystem | Out-GridView


Get-ADComputer sirki01-xp -Properties * |fl

Get-Service -ComputerName usilasd00317

Get-ADComputer –filter * -Properties SamAccountName,OperatingSystem,LastLogonDate |select-object SamAccountName,OperatingSystem,LastLogonDate | export-csv C:\Users\salmo07\Desktop\AD_Computers_Data.csv -notypeinformation


Search-ADAccount -PasswordNeverExpires | select-object DistinguishedName,Name | export-csv C:\Users\salmo07\Desktop\list.csv -notypeinformation
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | select-object DistinguishedName,Name | export-csv C:\Users\salmo07\Desktop\AccountInactive.csv -notypeinformation



Get-ADGroupMember -identity “usilws533b Admin Global Group - ca.com” | select name 

Get-ADComputer -Filter * -Properties name, ipv4Address, ipv6Address, OperatingSystem , LastLogonTimeStamp |select-object name, ipv4Address, ipv6Address, OperatingSystem , LastLogonTimeStamp | export-csv Computer_list.csv -notypeinformation




get-aduser "sg-salmo07" -Properties PasswordNotRequired | set-aduser -PasswordNotRequired $true 
get-aduser "sg-salmo07" -Properties PasswordNotRequired | select PasswordNotRequired



$Row=2;
do {
  $data=$Sheet.Range("A$Row").Text
  write-host "k $($data) already updated"
  $Row++

  }While ($data)
