


$user="Islandia, NY - 2A2"
$phone="78997"

$pwd="P@55word"
$cred=ConvertTo-SecureString $pwd -AsPlainText -force

$lgn=$($user -replace " ")
$lgn=$($lgn -replace "-")
$userlgn=$($lgn -replace ",")


New-ADUser -name $userlgn -UserPrincipalName "$userlgn@catest.com" -DisplayName $user -Path 'OU="Room Mailbox",OU=Role-Based,OU=North America,DC=catest,DC=com' -AccountPassword $cred -Enabled $false -OfficePhone $phone -EmailAddress "$userlgn@catest.com" 

$CapacityUpdate = Get-ADUser $userlgn -Properties msExchResourceCapacity
$CapacityUpdate.'msExchResourceCapacity' = 6
Set-ADUser -instance $CapacityUpdate

$ResourceDisplayUpdate = Get-ADUser $userlgn -Properties msExchResourceDisplay
$ResourceDisplayUpdate.'msExchResourceDisplay' = "Room"
Set-ADUser -instance $ResourceDisplayUpdate

