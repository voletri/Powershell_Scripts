$names = Get-Content  "C:\Users\salmo07\Desktop\a\users_list.txt"

foreach ($name in $names) {

$k=Get-aduser $name -Filter * -Properties DistinguishedName | select-object DistinguishedName
write-output "$($k.DistinguishedName) is the owner of $($name)" 

}

$k=Get-ADUser "salmo07"
(Get-ACL 'AD:\$($k.DistinguishedName)').Owner | out-file C:\Users\salmo07\Desktop\a\owner.txt -append 



