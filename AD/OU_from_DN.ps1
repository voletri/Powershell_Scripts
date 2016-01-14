
<#####################################################################################
.NAME: Get-OU_from_DN.ps1

.Purpose:
    This Script is used to get the OU info from DistinguishedName

.Notes:
    This Script requires AD Module
    
    Run the Script as .\Get-OU_from_DN.ps1
    Developed on Powershell Version 4

.Author: salmo07
######################################################################################>


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

#Examples 
Get-ADcomputer "usilap11" |select Name,DistinguishedName,@{L="OU";E={Get-OU $($_.DistinguishedName)}}
Get-ADUser "salmo07" |select Name,DistinguishedName,@{L="OU";E={Get-OU $($_.DistinguishedName)}}
Get-ADGroup "ssl monitor" |select Name,DistinguishedName,@{L="OU";E={Get-OU $($_.DistinguishedName)}}

Get-Content C:\Temp\OU.txt|%{ 

$object=$_

    try{
        Get-ADcomputer $object |select Name,@{L="OU";E={Get-OU $($_.DistinguishedName)}}
    }catch{
        {}|select @{l="Name";E={$object}},@{l="OU";E={"Computer Account not Found"}}
    }
}|export-csv C:\Temp\OU_output.csv -NoTypeInformation