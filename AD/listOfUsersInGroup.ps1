
clear
$erroractionpreference = “SilentlyContinue”

$List = get-content C:\Users\salmo07\Desktop\ad\groupNamesList.txt


write-host "before for loop"

foreach($groupName in $List)
{
write-host $groupName

$fileName="$($groupName).csv"
write-host $fileName

Get-ADGroupMember -identity $groupName | select name | export-csv C:\Users\salmo07\Desktop\ad\$fileName -notypeinformation

write-host "file created"

}

write-host "after for loop"





