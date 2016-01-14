$names = Get-Content  "C:\Users\salmo07\Desktop\a\users_list.txt"

foreach ($name in $names) {

Get-aduser $name -properties * | export-csv C:\Users\salmo07\Desktop\a\$name.csv -notypeinformation

}


