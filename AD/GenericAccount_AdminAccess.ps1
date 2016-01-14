
############################################
# generic users who have accesss to servers
############################################

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(Title -notlike "*") -and (name -notlike "sg-*")} -Properties MemberOf|where{$_.MemberOf -like "*Admin Global Group - ca.com*"}`
|select SamAccountName,Enabled,@{l="Servers";e={($_.MemberOf|%{if($_ -match 'Admin Global Group - ca.com'){($_ -split " ")[0].Substring(3)}}) -join ','}} |Export-Csv C:\Temp\GenericUser_admingroups11.csv -NoTypeInformation

#######################################################################################
# Security Groups which have accesss to servers and also has generic users as members
########################################################################################

$grouplist=Get-ADGroup -SearchBase "DC=ca,DC=Com" -Filter{name -like "*"} -Properties MemberOf|where{$_.MemberOf -like "*Admin Global Group - ca.com*"}`
|select SamAccountName,GroupCategory,@{l="Servers";e={($_.MemberOf|%{if($_ -match 'Admin Global Group - ca.com'){($_ -split " ")[0].Substring(3)}}) -join ','}},GenricMembers

foreach($group in $grouplist){
    
    $group.GenricMembers=((Get-ADGroupMember $($group.SamAccountName) -Recursive|%{  
    $b=$_.SamAccountName;
    
    if((Get-ADObject -LDAPFilter SamAccountName=$b -SearchBase "dc=ca,dc=com"|select -ExpandProperty ObjectClass) -eq "User"){
        $a=Get-ADUser $b -Properties Title;
        if(($($a.Title) -eq $null) -and ($($a.SamAccountName) -notlike "sg-*")){
            $a.SamAccountName
        }
    }}) -join ',')
}

$grouplist|where{!([string]::IsNullOrEmpty($_.GenricMembers))}|export-csv C:\Temp\genericusers_in_securitygroups_withAdminGroups.csv -NoTypeInformation

##################################################################################



Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {Title -notlike "*"} -Properties MemberOf|where

Get-ADUser "DMGADMIN" -Properties MemberOf|select SamAccountName,@{l="AdminGroups";e={($_.MemberOf|%{if($_ -match 'Admin'){($_ -split " ")[0].Substring(3)}}) -join ','}}

Get-ADUser "DMGADMIN" -Properties MemberOf|select -ExpandProperty MemberOf

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {name -like "sg-*"} -Properties MemberOf|where{$_.MemberOf -like "*Admin Global Group - ca.com*"}

