<##################################################

Universal Security Enabled Groups (DL)
When Created
External Facing
Owner
Memberof
Servers Access

#################################################>

$E=(Get-Content C:\Temp\list.txt).count
$i=0

Get-Content C:\Temp\list.txt|%{
$i++

Write-Progress -activity “Checking for Server: ($i of $E) >> $Server" -perc (($i / $E)*100) -Status "Processing...."

$g=$_;

Get-DistributionGroup $g|select WhenCreated,@{l="External_Facing";e={if($_.RequireSenderAuthenticationEnabled){"False"}else{"True"}}},`
@{l="owner";e={if($_.ManagedBy -ne $null){$count=($_.ManagedBy -split '/').Count;($_.ManagedBy -split '/')[$count-1]}}},DisplayName,PrimarySmtpAddress,`
@{L="MemberOf";e={
Get-ADGroup $_.DisplayName -Properties MemberOf|select @{l="GroupMemberOf";e={($_.MemberOf|%{(($_ -split ',')[0]).Substring(3)}) -join ';' }}|select -ExpandProperty GroupMemberOf
}}`
|select DisplayName,PrimarySmtpAddress,External_Facing,WhenCreated,Owner,MemberOf,`
@{L="ServerAccess";e={
Get-ADGroup $_.DisplayName -Properties MemberOf|select @{l="Servers";e={($_.MemberOf|%{if($_ -match 'Admin Global Group - ca.com'){($_ -split ' ')[0].Substring(3)}}) -join ','}}|select -ExpandProperty Servers
}}

}|Export-Csv C:\Temp\dl_SecurityEnabled.csv -NoTypeInformation