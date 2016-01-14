$DeletedUserList = get-content C:\PowershellScripts\DeletedUserList.txt

foreach ($User in $DeletedUserList)
{
$data=Get-ADObject -Filter {samaccountname -eq $User} –IncludeDeletedObjects
$check=$data.Deleted;
Write-Host $check
}
