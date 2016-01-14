﻿$Report = @()
$GroupCollection = Get-ADGroup -Filter * | select Name,MemberOf,ObjectClass,SAMAccountName

Foreach($Group in $GroupCollection){
$MemberGroup = Get-ADGroupMember -Identity $Group.SAMAccountName | where{$_.ObjectClass -eq ‘group’}
$MemberGroups = ($MemberGroup.Name) -join “`r`n”
if($MemberGroups -ne “”){
$Out = New-Object PSObject
$Out | Add-Member -MemberType noteproperty -Name ‘Group Name’ -Value $Group.Name
$Out | Add-Member -MemberType noteproperty -Name ‘Member Groups’ -Value $MemberGroups

    $Report += $Out
}
}
$Report | Sort-Object Name | FT -AutoSize
$Report | Sort-Object Name | Export-Csv -Path ‘C:\Group-MemberGroups-Report.csv’ -NoTypeInformation