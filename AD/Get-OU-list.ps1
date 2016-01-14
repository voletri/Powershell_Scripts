
function Get-OU ([String]$DistinguishedName){
               
        $o=$null
        foreach($f in $((($DistinguishedName -split “,”, 2)[1]).Split(',')))        
        {
            if($f.SubString(0,3) -ne 'DC='){            
                $o="/"+$f.SubString(3)+$o                
            }              
        }         
        $o="ca.com"+$o;
        return $o   
 } 
    

    $InputFile="C:\Temp\ServerList.txt"

    $ServerList = Get-Content $InputFile

    $Output=@()
    
    foreach($Server in $ServerList){
        
        $o=$Null
        $o=Get-ADcomputer $Server -Properties * |select Name,@{L="OU";E={Get-OU $($_.DistinguishedName)}}
        
        if($o -eq $Null){
        $o={}|select Name,OU
        $o.Name=$Server
        $o.OU="NotFound"        
        }
        $o
        $Output+=$o
    }

    $Output|Export-Csv "c:\temp\Get-OU-Output.csv" -NoTypeInformation
