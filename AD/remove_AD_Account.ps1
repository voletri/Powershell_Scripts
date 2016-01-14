$membersList = get-content C:\PowershellScripts\user.txt

foreach ($member in $membersList)
{
Write-Host $member
remove-ADUser -Identity $member 
}
