Function Get-Name_From_DN([String]$DistinguishedName){
        
        return $(($DistinguishedName -split ",")[0].Substring(3))   
}


function Get-ADGroup_SubMemberGroups ([String]$Account) {
		
    $GroupMem=Get-ADGroup $Account -Properties member | Select-Object -ExpandProperty member | %{Get-ADObject $_|where{$_.ObjectClass -eq "group"}|select -ExpandProperty DistinguishedName}
    
    $($GroupMem)
        
    if($GroupMem.count -ne 0){
        
        foreach($g in $GroupMem){

            if($CircularGroups -notcontains $g){
                Get-ADGroup_SubMemberGroups $g
            }else{
                         "CircularGroups"            
             break
            }
        }
    }
    
     
}

#Get-ADGroup -Filter *  -Properties members |where{$_.members -contains $_.DistinguishedName}|select Name,MemberOf,ObjectClass,SAMAccountName,members

$GroupCollection = Get-ADGroup -Filter * -Properties members |where{$_.members -notcontains $_.DistinguishedName}| select -ExpandProperty DistinguishedName
$GroupCollection|Out-File C:\Temp\all_gm_dn.txt
$GroupCollection|%{Get-Name_From_DN $_}|Out-File C:\Temp\all_gm.txt
$CircularGroups=Get-Content "C:\Temp\circular_nesting.txt"

$GroupCollection|%{

    $subGrouplist=$null
    $group=$_

    if($CircularGroups -notcontains $group){

        $subGrouplist=Get-ADGroup_SubMemberGroups $group

        if($subGrouplist -contains "CircularGroups"){

        if($subGrouplist -ne $null){
            {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={$($subGrouplist|%{Get-Name_From_DN $_}) -join “`r`n”}},@{L="SUBGroupsCount";E={$subGrouplist.count}}
        }else{
        
            {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={"No SUBGroups"}},@{L="SUBGroupsCount";E={"No SUBGroups"}}    
        }
    }else{
        {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={"Circular_Group"}},@{L="SUBGroupsCount";E={"Circular_Group"}}    
    }
    }else{
        {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={$($subGrouplist|%{Get-Name_From_DN $_}) -join “`r`n”}},@{L="SUBGroupsCount";E={"Circular_Group"}}    
    }
}|export-csv C:\Temp\gm_all1.csv -NoTypeInformation