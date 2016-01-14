
#Get the Location of a AD Account from DN

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

#Stale Computers
$lastSetdate = [DateTime]::Now - [TimeSpan]::Parse("90")
Get-ADComputer -Filter {PasswordLastSet -le $lastSetdate} -Properties passwordLastSet,OperatingSystem -ResultSetSize $null | select samaccountname,Name,OperatingSystem,PasswordLastSet,@{L="OU";E={Get-OU $($_.DistinguishedName)}} |Export-csv C:\Temp\stale_AD_Accounts_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation 