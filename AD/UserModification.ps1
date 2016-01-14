$userList = get-content C:\PowershellScripts\user.txt

foreach ($userPmfKey in $userList)
{
write-host " User pmfkey $($userPmfKey)"
get-aduser $userPmfKey -Properties PasswordNotRequired | set-aduser -PasswordNotRequired $false 
write-host "Properties of $($userPmfKey) has been modified successfully" 
}

write-host "completed"