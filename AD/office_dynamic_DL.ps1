
$outfile="C:\Temp\dynamicdl1.csv"

$ddl=Get-DynamicDistributionGroup -Filter {name -like "office*"} -ResultSize unlimited|select Name,LdapRecipientFilter,RecipientFilter
#$ddl=Get-DynamicDistributionGroup -Filter {name -like "office*"} -ResultSize 20|select Name,LdapRecipientFilter,RecipientFilter

$ddl.count

$ddl|%{

$dl=$_

    try{
    
        Get-Recipient -RecipientPreviewFilter $dl.RecipientFilter -ErrorAction stop|Out-Null
        {}|select @{l="DL_name";e={$dl.Name}},@{l="Status";e={"pass"}},@{l="LdapRecipientFilter";e={$dl.LdapRecipientFilter}},@{l="RecipientFilter";e={$dl.RecipientFilter}}

    }catch{
    
        {}|select @{l="DL_name";e={$dl.Name}},@{l="Status";e={"Fail_$($Error[0])"}},@{l="LdapRecipientFilter";e={$dl.LdapRecipientFilter}},@{l="RecipientFilter";e={$dl.RecipientFilter}}
    }

}|export-csv $outfile -NoTypeInformation