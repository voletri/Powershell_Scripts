
$NameList= get-content C:\temp\email_con.txt

$List=$NameList
$List=$NameList|select -First 5

$searchRoot = New-Object System.DirectoryServices.DirectoryEntry
$adSearcher = New-Object System.DirectoryServices.DirectorySearcher
$adSearcher.SearchRoot = $searchRoot
$adSearcher.PropertiesToLoad.Add(“userprincipalname”)

$o=@()
foreach ($Name in $List)
{
    $Name=$Name.Trim()

    $adSearcher.Filter = “(proxyaddresses=*$Name)”
    $samResult=$Null
    $samResult = $adSearcher.FindOne()
    $UserDetails=$null    

    $UserDetails={}|select GivenEmail,UserPrincipalName
    $UserDetails.GivenEmail=$Name
    
    if(!([string]::IsNullOrEmpty($samResult)))
    {
       $UserDetails.UserPrincipalName=[string]$samResult.Properties[“userprincipalname”]        
    }else{
       $UserDetails.UserPrincipalName="UnableToRetrieve-adsi"
    }
    $UserDetails|Export-Csv "C:\Temp\email_proxy_adsi.csv" -NoTypeInformation -Append
    $o=$o+$UserDetails
}
#$o|Export-Csv "C:\Temp\email_proxy_adsi.csv" -NoTypeInformation