
$list=Get-ADUser -Filter {(Name -like "*") -and (extensionAttribute2 -like "outlook*") } -Properties SamAccountName,extensionAttribute2,proxyAddresses,mail | where-object {$_.proxyAddresses -contains "SIP:$($_.mail)"}|select SamAccountName,proxyAddresses
$t=$list|select -First 1
$t.proxyAddresses

$list1=Get-ADUser -Filter {(Name -like "*") -and (extensionAttribute2 -like "outlook*") } -Properties SamAccountName,extensionAttribute2,proxyAddresses,mail |select SamAccountName,proxyAddresses
$list1.count


$list2=Get-ADUser -Filter {(Name -like "*") -and (extensionAttribute2 -like "outlook*") } -Properties SamAccountName,extensionAttribute2,proxyAddresses,mail | where-object {$_.proxyAddresses -notcontains "SIP:$($_.mail)"}|select SamAccountName,proxyAddresses
$list2.count

$t3=$list2|select SamAccountName

$t3.SamAccountName




