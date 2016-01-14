
<#
.NAME: Get-AD-EAS.ps1
.Purpose:
    This Script Retrieves the OS for the given list of Servers

.Notes:
    Input File: "C:\temp\ServerList.txt"
    Output File will be generated in "C:\Temp\"
    
    Run the Script as .\Get-OS.ps1

.Author: salmo07
.Created Date: 1st September 2015

#>


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$Date = $(get-date -f "yyyy-MM-dd_HH-mm-ss")     

$InputFile="C:\temp\eas.txt"
$OutputFile="C:\Temp\easListResults_$Date.csv"

if(Test-Path $InputFile){

$ServerList = Get-Content $InputFile

$Output=@()

$E=$($ServerList.count)
$i=0

 Write-Host ""
 Write-Host "--------------------------------------------"
 Write-Host "Total Count of Servers to be Processed - $E"
 Write-Host "--------------------------------------------"

Get-Content $InputFile|%{ 

    $i++
    $_=$_.Trim()

    Write-Progress -activity “Checking for Server: ($i of $E) >> $_" -perc (($i / $E)*100) -Status "Processing...."
    
    try{
        
        $a=$Null
        $a=Get-ADUser $_
        Get-ADObject -SearchBase $a.DistinguishedName -filter *|select Name,@{L="Status";E={"Active"}},ObjectClass,DistinguishedName    
    
    }catch{
        {}|select @{L="Name";e={$_}},@{L="Status";E={"InactiveActive"}},ObjectClass,DistinguishedName
    }

 }|Export-Csv $OutputFile -NoTypeInformation

Write-Host "................................................."

Write-Host "__ Output Saved in  $OutputFile __" -ForegroundColor Green

}else{

Write-Host "__ Input file Not found in the following path C:\temp\ServerList.txt __" -ForegroundColor Red

}

Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="