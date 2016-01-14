$i=1
$list=@()

do {

$k="salte"+$i

#Write-Host $k

$list=$list+$k
$i++
}while ($i -le 400)

$newpwd = ConvertTo-SecureString -String "P@55word1" -AsPlainText –Force

foreach($user in $list){

Get-ADUser $user –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed"|Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
#Set-ADAccountPassword $user -NewPassword $newpwd –Reset

}
