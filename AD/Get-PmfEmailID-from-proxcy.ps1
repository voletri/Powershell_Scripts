
$NameList= get-content C:\temp\email.txt
#$List=$NameList|select -First 10
$List=$NameList

$o=@()
foreach ($Name in $List)
{
    $Name=$Name.Trim()
    $UserDetails=$null    
    
    #$UserDetails =Get-ADUser -Filter {mail -eq $Name}| select @{L="GivenEmail";E={$Name}},UserPrincipalName
    $UserDetails =Get-ADUser -LDAPFilter "(proxyAddresses=*:$Name)" -ResultPageSize 10000 -ResultSetSize 1 -SearchBase "DC=ca,DC=com" | select @{L="GivenEmail";E={$Name}},UserPrincipalName
    
            if([string]::IsNullOrEmpty($UserDetails)){
                $UserDetails={}|select GivenEmail,UserPrincipalName
                $UserDetails.GivenEmail=$Name
                $UserDetails.UserPrincipalName="UnableToRetrieve"
            }

    $UserDetails
    $o=$o+$UserDetails
}
$o|Export-Csv "C:\Temp\email_proxy.csv" -NoTypeInformation