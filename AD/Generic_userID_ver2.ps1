$i=151
$list=@()

do {

$k="salte"+$i

#Write-Host $k

$list=$list+$k
$i++
}while ($i -le 200)

$cred = Get-Credential
#$pwd ="P@55word"

#$c=ConvertTo-SecureString $pwd -force -asPlainText

foreach($user in $list){

New-ADUser -Name $user -GivenName $GivenName -Surname $Surname -DisplayName $user -Path 'OU=Role-Based,OU=North America,DC=ca,DC=com' -AccountPassword $cred.password -Description "200-119586 owner: Mitchell, Michael" -EmailAddress "$($user)@ca.com" -UserPrincipalName "$($user)@ca.com"-ChangePasswordAtLogon $false -PasswordNeverExpires $false -CannotChangePassword $true -Enabled $true -PassThru

}

$user="salte54"
#New-ADUser -Name $user -GivenName $user -DisplayName $user -Path 'OU=Role-Based,OU=North America,DC=ca,DC=com' -AccountPassword $cred.password -Description "200-113542 owner: Rajendran, Murali" -EmailAddress "$($user)@ca.com" -UserPrincipalName "$($user)@ca.com"-ChangePasswordAtLogon $false -PasswordNeverExpires $false -CannotChangePassword $true -Enabled $true -PassThru

Get-ADUser SALTE201 -Properties *|select *Name


$user="SALTE201"
$GivenName="Compass"
$Surname="Tester201"

New-ADUser -Name $user -GivenName $GivenName -Surname $Surname -DisplayName $user -Path 'OU=Role-Based,OU=North America,DC=ca,DC=com' -AccountPassword $cred.password -Description "200-119586 owner: Mitchell, Michael" -EmailAddress "$($user)@ca.com" -UserPrincipalName "$($user)@ca.com"-ChangePasswordAtLogon $false -PasswordNeverExpires $false -CannotChangePassword $true -Enabled $true -PassThru

