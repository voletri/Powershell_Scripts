
##########################################################################################
<#
.NAME: Get-Password-Expiration.ps1

.SYNOPSIS 
    Resets the AD Domain Account Password for the given list of users to the New Password

.NOTES
    AD Powershell Module is Required to Run the Script
    
    Input Should be placed in the following path C:\temp\UserList.txt
    Run the Script as .\Set-Password-Reset.ps1 

    AUTHOR: SALMO07
    LASTEDIT: May 28, 2015
    Developed on Powershell Version 4
#>
##########################################################################################

Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

try{
If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
} 
 
 If(-not(Get-Module -Name ActiveDirectory)){
    
    write-host "You Need AD Module to Run this Script" -foregroundcolor Red
    
 }else{   

$InputFile="C:\temp\UserList.txt"

if(Test-Path $InputFile){
    
    $UserList = Get-Content $InputFile

    $E=$($UserList.count)
    $i=0

    Write-Host ""
    Write-Host "--------------------------------------------"
    Write-Host "Total Count of Generic UserID to be Processed - $E"
    Write-Host "--------------------------------------------"
    
    $Output=@()
    
    foreach($user in $UserList){
        
        $userDetails = {} | Select PMF,DisplayName,PresentExpiryDate
        
        $userCheckPre=$null
        $userDetails.PMF=$user
        
        try{

            $userCheckPre=Get-ADUser $user -Properties samaccountname,Displayname,"msDS-UserPasswordExpiryTimeComputed"|select samaccountname,Displayname,@{Name="PresentExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

            $userDetails.Displayname=$userCheckPre.Displayname
            $userDetails.PresentExpiryDate=$userCheckPre.PresentExpiryDate
            

        }Catch [System.UnauthorizedAccessException] 
        {
           $userDetails.Status="Access Denied"
        }
        Catch
        {            
            $userDetails.Status="User Not Found/Unable to process"
        }
    
        finally
        {
            $userDetails
            $Output=$Output+$userDetails
        }    
    }
    
    $Output|export-csv C:\Temp\PasswordExpiryResults_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation

}else{

    Write-Host ""

    Write-Host "Input file Not found in the following path $($InputFile)" -ForegroundColor Red
    Write-Host ""

}

}
}catch{
    Write-Host ""
    write-host "You Need have AD Module to Run this Script" -foregroundcolor Red
    Write-Host ""
}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host "==============================================================================="