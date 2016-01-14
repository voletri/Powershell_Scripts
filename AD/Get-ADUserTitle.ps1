

<#####################################################################################
.NAME: Get-ADUserCheck.ps1

.Purpose:
    This Script Checks if an AD Account exist for given list of Users

.Notes:
    Input File: "C:\temp\UserList.txt"
    Output File: "C:\Temp\ADUserTitle-Status followed by current timestamp
    
    Run the Script as .\Get-ADUserTitle.ps1
    Developed & Tested on Powershell Version 4

.Author: salmo07
.Created: 4th Nov 2015
######################################################################################>


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$modulecheck=$true
Try {

 If(-not(Get-Module -Name "ActiveDirectory")){

  Import-Module -Name ActiveDirectory

 }

} Catch {

 $modulecheck=$false
 Write-Warning "Failed to Import REQUIRED Active Directory Module...exiting script!”

 Break

}

if($modulecheck){

#Input File Location
$InputFile="C:\temp\UserList.txt"
$Date = $(get-date -f "yyyy-MM-dd_HH-mm-ss")     

$OutputFile="C:\Temp\ADUserTitle-Status_$Date.csv"

if(Test-Path $InputFile){

 $UserList = Get-Content $InputFile

 $Output=@()

 $E=$($UserList.count)
 $i=0

 Write-Host ""
 Write-Host "--------------------------------------------"
 Write-Host "Total Count of Users to be Processed - $E"
 Write-Host "--------------------------------------------"


 Get-Content $InputFile|%{ 
    
    $User=$_
    
    $i++
    $User=$User.Trim()

    Write-Progress -activity “Checking for Server: ($i of $E) >> $User" -perc (($i / $E)*100) -Status "Processing...."
    
    Try { 
    
        $UserStatus=$Null  
        
        Get-ADUser -Identity $User -Properties Title,Displayname| Select samaccountname,@{l="Status";e={"Active"}},Displayname,Title
        
    }catch{
    
        {}|select @{l="samaccountname";e={$User}},@{l="Status";e={"InActive"}},Displayname,Title
    
    }   

 }|Export-Csv $OutputFile -NoTypeInformation

 Write-Host "................................................."
 Write-Host "__ JOB DONE __" -ForegroundColor Green
 Write-Host "__ Output Saved in  $OutputFile __" -ForegroundColor Green

}else{

    Write-Host "__ Input file Not found in the following path $InputFile __" -ForegroundColor Red

    }
}
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="