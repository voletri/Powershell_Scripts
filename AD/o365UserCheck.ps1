


#$list=Get-Content C:\Temp\input.txt
$list="salmo07","salmo","thoni08"
$o=@()

foreach($user in $list){
$c={}|select Name,extensionAttribute2
$c=Get-ADUser $user -Properties * |select Name,extensionAttribute2
$c|Add-Member -Name pmf -MemberType NoteProperty -Value $user
$o=$o+$c
}

$o|export-csv c:\temp\365.csv -NoTypeInformation

Invoke-Item c:\temp\365.csv

