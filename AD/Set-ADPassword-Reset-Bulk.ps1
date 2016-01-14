
##########################################################################################
<#
.NAME: Set-ADPassword-Reset-Bulk.ps1

.SYNOPSIS 
    Resets the AD Domain Account Password for the Given list of Users to a New Password

.PARAMETER NewPassword    
    Specify the New Password you want to give it to all the list of users

.NOTES
    AD Powershell Module is Required to Run the Script
    
    Input Should be placed in the following path C:\temp\PasswordResetUserList.txt with End Users PMFKey
    Example: salmo06
             thoni06
             redye02

    Output will be generated in C:\temp
      
    Run the Script as .\Set-ADPassword-Reset-Bulk.ps1 -NewPassword P@55word
 
 .Changelog:
    Created script: May 28, 2015: 
    LASTEDIT: July 7th, 2015

    AUTHOR: SALMO07
    Developed on Powershell Version 4
#>
##########################################################################################

param
    (
        [parameter(Mandatory=$true)]
        [String]
        $NewPassword
    )

Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

 
 $a="true"

try{

    If(-not(Get-Module -Name ActiveDirectory))
    {
        Write-Host "Trying to Add Active Directory Module....." -ForegroundColor Green
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

    $InputFile="C:\temp\PasswordResetUserList.txt"

    if(Test-Path $InputFile){
    
    $UserList = Get-Content $InputFile

    $E=$($UserList.count)
    $i=0

    Write-Host ""
    Write-Host "-----------------------------------------------------"
    Write-Host "Total Count of Generic UserID to be Processed - $E"
    Write-Host "-----------------------------------------------------"
    Write-Host ""
    
    $Output=@()
    
    foreach($user in $UserList){
        
        $userDetails = {} | Select PMF,DisplayName,Status,OldExpiryDate,PresentExpiryDate
        
        $userCheckPre=$null
        $userCheckPost=$null
        $userDetails.PMF=$user
        
        try{

            $userCheckPre=Get-ADUser $user -Properties samaccountname,Displayname,"msDS-UserPasswordExpiryTimeComputed"|select samaccountname,Displayname,@{Name="OldExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
            #Set-AdaccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)

            $userDetails.Displayname=$userCheckPre.Displayname
            $userDetails.OldExpiryDate=$userCheckPre.OldExpiryDate
            $userCheckPost=Get-ADUser $user -Properties samaccountname,Displayname,"msDS-UserPasswordExpiryTimeComputed"|select samaccountname,Displayname,@{Name="PresentExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
            $userDetails.PresentExpiryDate=$userCheckPost.PresentExpiryDate
            
            $diff=$null
            $diff=NEW-TIMESPAN –Start $($userDetails.PresentExpiryDate) –End $($userDetails.OldExpiryDate)

            if($diff -eq "00:00:00"){           
               $userDetails.Status="Password Reset Not Succesfull_$($diff)"
            }else{
               $userDetails.Status="Password Reset Succesfull"
            }

        }Catch [System.UnauthorizedAccessException] 
        {
           $userDetails.Status="Access Denied"
        }
        Catch
        {            
            $userDetails.Status="User Not Found/Unable to Process"
        }
    
        finally
        {
            Write-Host ""
            $userDetails
            Write-Host ""
            $Output=$Output+$userDetails
        }    
    }
    
    $OutputFile="C:\Temp\PasswordExpiryResults_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"
    
    $Output|export-csv $OutputFile -NoTypeInformation

    Write-Host ""    
    Write-Host ""

    Write-Host "Output file is located  in the following path " -NoNewline
    Write-Host "$($OutputFile)" -ForegroundColor yellow

    Write-Host ""    
    Write-Host ""


}else{

    Write-Host ""
    Write-Host ""

    Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
    Write-Host "$($InputFile)" -ForegroundColor yellow

    Write-Host ""
    Write-Host ""

}

}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "==============================================================================="