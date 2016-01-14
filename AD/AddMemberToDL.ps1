$membersList = Get-DistributionGroupMember "AI-SAP-BASIS"

$membersList=$membersList.name


foreach ($member in $membersList)
{
Add-ADGroupMember -Identity "USILASP00169 Admin Global Group - ca.com" -Members $member
Add-ADGroupMember -Identity "USILASP00170 Admin Global Group - ca.com" -Members $member
Add-ADGroupMember -Identity "USILASD00330 Admin Global Group - ca.com" -Members $member
Add-ADGroupMember -Identity "USILASD00331 Admin Global Group - ca.com" -Members $member
}
