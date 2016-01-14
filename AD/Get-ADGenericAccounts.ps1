
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

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(-not(Title -like "*"))}  -Properties *|select SamAccountName,@{L="AccountStatus";E={if($_.Enabled){"Enabled"}else{"Disabled"}}},Manager,LastLogonDate,@{L="Account_location_OU";E={Get-OU $($_.DistinguishedName)}},@{l="MemberOfGroups";e={$_|select -ExpandProperty memberof}}|Export-Csv C:\Temp\All_Generic_AD_Accounts.csv -NoTypeInformation