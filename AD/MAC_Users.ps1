
#Get the OU of a AD Account from DN
function Get-OU ([String]$DistinguishedName){
               
        $o=$null
        foreach($f in $((($DistinguishedName -split “,”, 2)[1]).Split(',')))        
        {
            if($f.SubString(0,3) -ne 'DC='){            
                $o="\"+$f.SubString(3)+$o                
            }              
        }         
        $o="ca.com"+$o;
        return $o   
 }


###### MAC OU
Get-ADComputer -filter * -SearchBase "ou=MAC,ou=Computers,dc=ca,dc=com" -Properties Name,OperatingSystem,PasswordLastSet|`
select Name,OperatingSystem,PasswordLastSet,@{L="OU";E={Get-OU $($_.DistinguishedName)}}|export-csv C:\Temp\MAC_OU.csv -NoTypeInformation

###### MAC OS
Get-ADComputer -filter {OperatingSystem -eq "Mac OS X"} -Properties Name,OperatingSystem,PasswordLastSet|`
select @{l="ComputerName";e={$_.Name}},OperatingSystem,PasswordLastSet,@{L="OU";E={Get-OU $($_.DistinguishedName)}},@{l="Owner";e={(($_.name -split "mac")[0]).TrimEnd('-')}}|`
select ComputerName,OperatingSystem,PasswordLastSet,OU,Owner,@{l="OwnerADCheck";e={$ownerName=$null;try{get-aduser $_.Owner|Out-Null;"User Exists"}catch{"User Not Found"}}}|`
export-csv C:\Temp\MAC_Devices_withowner_status.csv -NoTypeInformation