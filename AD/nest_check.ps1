$GroupCollection=Get-Content "C:\Temp\all_gm1.txt"
$CircularGroups=Get-Content "C:\Temp\circular_nesting.txt"

$GroupCollection|%{

    $subGrouplist=$null
    $group=$_

    if($CircularGroups -notcontains $group){

        $subGrouplist=Get-ADGroup_SubMemberGroups $group

        if($subGrouplist -ne $null){
            {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={$($subGrouplist|%{Get-Name_From_DN $_}) -join “`r`n”}},@{L="SUBGroupsCount";E={$subGrouplist.count}}
        }else{
        
            {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={"No SUBGroups"}},@{L="SUBGroupsCount";E={"No SUBGroups"}}    
        }
    }else{
        {}|select @{L="Groupname";E={Get-Name_From_DN $group}},@{L="SUBGroups";E={"Circular_Group"}},@{L="SUBGroupsCount";E={"Circular_Group"}}    
    }

}|export-csv C:\Temp\gm_all2.csv -NoTypeInformation