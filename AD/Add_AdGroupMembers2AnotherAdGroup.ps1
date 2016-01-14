
#Check if ActiveDirectory module is imported, if not import AD Module
If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
}

#Please specify the Old AD Group in below
$old_ADGroup="LG USILFS70 SOX - R&D R"

#Please specify the New AD Group in below
$new_ADGroup="LG USILFS70 SOX - R&D R"

$membersList = Get-ADGroupMember $old_ADGroup
$membersList=$membersList.name

foreach ($member in $membersList)
{
Add-ADGroupMember -Identity $new_ADGroup -Members $member
}


