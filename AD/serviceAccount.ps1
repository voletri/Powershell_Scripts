
<#
.SYNOPSIS 
    This Script is used to create the Service Accounts

.DESCRIPTION
    This Script Retrives the PMFKey of given Email ID and Identifies if User Exists or Not.
    Access to Exchange Required,Run the Script with Credentials which has exchange Access
   
    Input Should be placed in the following path C:\Temp\email.txt
    Output will be saved in the following path C:\Temp\pmf_email.csv

.NOTES
    AUTHOR: SALMO07
    LASTEDIT: July 10, 2015
    Developed on Powershell Version 4
#>


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$a="true"

try{

    If(-not(Get-Module -Name ActiveDirectory))
    {
        Import-Module -Name ActiveDirectory -ErrorAction Stop
    } 
    
}catch{
    
    $a="false"

    Write-Host ""
    Write-Host ""
    write-host "You Need have AD Module to Run this Script" -foregroundcolor Red
    Write-Host ""
    Write-Host ""
}   

if($a){

    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

    $Server=$null
    $Server = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter the Server Name", "Service Account Creation", "Server_Name")

    if(!([String]::IsNullOrEmpty(($Server)))){
        
        $count=0
        
        do{
            $c='OK'
            if($count -ge 0){
                     
                     $c=[Microsoft.VisualBasic.Interaction]::msgbox("Service Account Already Exists",'OKCANCEL',"Service Account creation")
            }
            
            if($c -eq 'OK'){
                
                $ServiceAccountName = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter the Service Account Name", "Service Account Creation", "$Server-")
                
                $preCheck=$null
                $preCheck=Get-ADServiceAccount $ServiceAccountName -ea 0
                $preCheck
            }
            $count++
         }while((!([String]::IsNullOrEmpty(($($preCheck.Name))))) -and($c -eq 'OK'))

         "i'm here"

         New-ADServiceAccount -Name $ServiceAccountName -Path "CN=Managed Service Accounts,DC=CA,DC=COM"
         Add-ADComputerServiceAccount -Identity $Server  -ServiceAccount $ServiceAccountName
    
            $postCheck=$null
            $postCheck=Get-ADServiceAccount $ServiceAccountName
    
            if($($postCheck.Name) -ne $null){
                Write-Host "$($postCheck.Name) is created Successfully"
            }else{
                Write-Host "Unable to create $($ServiceAccountName)"
            }
        }else{

        Write-Host "$($ServiceAccountName) Already Exists"
        }
    }else{
        
        [Microsoft.VisualBasic.Interaction]::msgbox("Server Name Should not be Empty",'OKOnly',"Service Account Creation")
        Write-Host "Server Name Should not be Empty"

    }


}    
 