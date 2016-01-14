$d = [DateTime]::Today.AddDays(-90) 

$stale = Get-ADComputer -Filter  'PasswordLastSet -le $d' -Properties OperatingSystem,PasswordLastSet|select Name,OperatingSystem,DistinguishedName,

@{l="OU";

    E={ $o=$null;

        foreach($f in $(($_.DistinguishedName).Split(',')))
        
        {
            if($f.SubString(0,3) -ne 'CN='){
            
            
             $o="\"+$f.SubString(3)+$o
                
            }
            
        
        } $o;


    }
 },PasswordLastSet 

$stale|export-csv C:\Temp\stale_OU.csv -NoTypeInformation