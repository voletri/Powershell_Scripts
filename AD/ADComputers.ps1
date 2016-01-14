
Get-ADComputer -filter * -Properties OperatingSystem,PasswordLastSet|select Name,OperatingSystem,DistinguishedName,@{L="LastPwdResetDays";E={$($(get-date) - $_.PasswordLastSet).Days}},PasswordLastSet,@{l="OU";

    E={ $o=$null;

        foreach($f in $(($_.DistinguishedName).Split(',')))
        
        {
            if($f.SubString(0,3) -ne 'CN='){
            
            
             $o="\"+$f.SubString(3)+$o
                
            }
            
        
        } $o;


    }
 } |export-csv C:\Temp\ADComputers.csv -NoTypeInformation
