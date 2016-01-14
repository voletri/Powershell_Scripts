

<#
.NAME: Get-SG-Status.ps1
.Purpose:
    This Script Checks if an SG Account exist for given list of Users
.Notes:
    Input File: "C:\temp\UserList.txt"
    Output File: "C:\Temp\SG-Status.csv"
    
    Run the Script as .\Get-SG-Status.ps1
    Developed on Powershell Version 4

.Author: salmo07
#>


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Try {

 If(-not(Get-Module -Name "ActiveDirectory")){

  Import-Module -Name ActiveDirectory

 }

} Catch {

 Write-Warning "Failed to Import REQUIRED Active Directory Module...exiting script!”

 Write-Warning "`nhttp://technet.microsoft.com/en-us/library/ee617195.aspx"

 Break

}


#Input File Location
$InputFile="C:\temp\UserList.txt"

if(Test-Path $InputFile){

$UserList = Get-Content $InputFile

$Output=@()

$E=$($UserList.count)
$i=0

 Write-Host ""
 Write-Host "--------------------------------------------"
 Write-Host "Total Count of Users to be Processed - $E"
 Write-Host "--------------------------------------------"


foreach ($User in $UserList)
{ 
    $i++
    $User=$User.Trim()

    Write-Progress -activity “Checking for Server: ($i of $E) >> $Server" -perc (($i / $E)*100) -Status "Processing...."

    $UserDetails = {} | Select User,SG_account,Status
    $UserDetails.User=$User
    $UserDetails.SG_account="SG-$User"
     
    $UserStatus=$Null    
    $UserStatus=(Get-ADUser -Identity "SG-$User").samaccountname
    
    if($UserStatus -eq $NUll){
        $UserDetails.Status="SG Account Not Found"   
    }else{
        $UserDetails.Status="SG Account Found"
    }   
    
    $UserDetails
    $Output=$Output+$UserDetails

 }
 $OutputFile="C:\Temp\SG_Status.csv"
 $Output|Export-Csv $OutputFile -NoTypeInformation

Write-Host "................................................."
Write-Host "__ JOB DONE __" -ForegroundColor Green
Write-Host "__ Output Saved in  $OutputFile __" -ForegroundColor Green

}else{

Write-Host "__ Input file Not found in the following path $InputFile __" -ForegroundColor Red

}

Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="