
$userList = get-content C:\PowershellScripts\user.txt

foreach ($userPmfKey in $userList)
{

$k=get-aduser $userPmfKey -Properties PasswordNotRequired | select PasswordNotRequired

if ($k.PasswordNotRequired -match "False")
{
write-host "$($userPmfKey) already updated"
}
else{
get-aduser $userPmfKey -Properties PasswordNotRequired | set-aduser -PasswordNotRequired $false 
write-host "$($userPmfKey) is modified"
}

}

