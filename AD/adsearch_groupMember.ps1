$searchRoot = New-Object System.DirectoryServices.DirectoryEntry
$adSearcher = New-Object System.DirectoryServices.DirectorySearcher
$adSearcher.SearchRoot = $searchRoot

$adSearcher.Filter = “(cn=Account Operators)”

$adSearcher.PropertiesToLoad.Add(“member”)
$samResult = $adSearcher.FindOne()

if($samResult)
{
$adAccount = $samResult.GetDirectoryEntry()
$groupMembership = $adAccount.Properties[“member”]
#$groupMembership | foreach { Write-Host $_ }
}
foreach ($member in $groupmembership) {

Get-ADUser -Filter {distinguishedname -eq $member} -Properties mail | Select-Object samAccountName, mail
}

#password not Required
Get-ADUser -searchbase "DC=ca,DC=com" -ldapfilter "(&(objectCategory=User)(userAccountControl:1.2.840.113556.1.4.803:=32))" 


#####
$username="Shamayel.Farooqui@ca.com"
$searchRoot = New-Object System.DirectoryServices.DirectoryEntry
$adSearcher = New-Object System.DirectoryServices.DirectorySearcher
$adSearcher.SearchRoot = $searchRoot
$adSearcher.Filter = “(proxyaddresses=*$username)”
$adSearcher.PropertiesToLoad.Add(“userprincipalname”)
$samResult = $adSearcher.FindOne()

if($samResult)
{
$adAccount = $samResult.GetDirectoryEntry()
$adAccount.Properties[“userprincipalname”]
}





if(([adsisearcher]"(proxyaddresses=*$username)").FindOne()) {
	"$username was found "
}
else {
	"$username not found "
}
###############