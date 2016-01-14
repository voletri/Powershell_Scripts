
$NameList= get-content C:\temp\email.txt
#$List=$NameList|select -First 10
$List=$NameList

$o=@()
foreach ($Name in $List)
{
    $Name=$Name.Trim()
    $UserDetails=$null
    $userID=($Name -split '@')[0]
    #$userID="suki.ma"
    
    if(($userID.Length -eq 7) -and ($userID -match '\d+')){    
            
            $UserDetails =Get-ADUser  -Filter {UserPrincipalName -eq $Name} -Properties mail,UserPrincipalName|select @{L="GivenEmail";E={$Name}},UserPrincipalName
            
            if([string]::IsNullOrEmpty($UserDetails)){
                $UserDetails={}|select GivenEmail,UserPrincipalName
                $UserDetails.GivenEmail=$Name
                $UserDetails.UserPrincipalName="UserNotFound"
            }   
    }else{
            $UserDetails =Get-ADUser -Filter {mail -eq $Name}| select @{L="GivenEmail";E={$Name}},UserPrincipalName
            #$UserDetails =Get-ADUser -LDAPFilter "(|(proxyAddresses=*:$Name)(mail=$Name))"| select @{L="GivenEmail";E={$Name}},UserPrincipalName
    
            if([string]::IsNullOrEmpty($UserDetails)){
                $UserDetails={}|select GivenEmail,UserPrincipalName
                $UserDetails.GivenEmail=$Name
                $UserDetails.UserPrincipalName="UnableToRetrieve"
            }
    }
    $UserDetails
    $o=$o+$UserDetails
}
$o
$o|Export-Csv "C:\Temp\pmf_email.csv" -NoTypeInformation