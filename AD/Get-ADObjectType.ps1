
$list=Get-Content C:\temp\shared_mailbox_users.txt

$list|%{
    Get-ADObject -LDAPFilter samaccountname=$_ -SearchBase "dc=ca,dc=com"|select Name,ObjectClass,@{l="Members";E={if($_.ObjectClass -eq "group"){$group=(Get-ADGroupMember $_.DistinguishedName -Recursive).name;if($group -ne $null){$($group -join ';')}else{"Unable to Retrieve"}}}}
}|Export-Csv C:\Temp\ad_user_type.csv -NoTypeInformation