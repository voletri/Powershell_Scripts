﻿
##########################################################################################
<#
.NAME: Get_Member_from_AD_AdminGroup_of_Servers.ps1

.SYNOPSIS 
    Gets the List of AD Group Members from the Associated AD Groups of Multiple Servers 

.NOTES
    AD Powershell Module is required to run the Script
    Excel is Required to Run this Script
    Input File should have ServerNames without .ca.com
    
    Input Should be placed in the following path C:\Temp\servers.txt
    
    Run the Script as .\Get_Member_from_AD_AdminGroup_of_Servers.ps1

    AUTHOR: SALMO07
    LASTEDIT: May 22, 2015
    Developed on Powershell Version 4

#>
##########################################################################################


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green


If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
}
  
 
 If(-not(Get-Module -Name ActiveDirectory)){
    
    write-host "You Need AD Module to Run this Script" -foregroundcolor Red
    
 }else{   
  
 
$InputFile="C:\Temp\servers.txt"  

if(!(Test-Path $InputFile)){ 

    write-host "Input File doesn't exist in the $($InputFile) path" -foregroundcolor Red

}else{

$ServerList= get-content $InputFile

$E=$($ServerList.count)
$i=0

 Write-Host ""
 Write-Host "--------------------------------------------"
 Write-Host "Total Count of Servers to be Processed - $E"
 Write-Host "--------------------------------------------"

$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'Server_AD_Group_Users'

$row = 1
$Sheet.Cells.Item($row,1)  ="Server Name"
$Sheet.Cells.Item($row,2)  ="AD Group Name"
$Sheet.Cells.Item($row,3)  ="MemberList"

$row++

 
  foreach($server in $serverList){

    $col=1
    $server=$server.Trim()

    $i++

    Write-Progress -activity “Checking for Server: ($i of $E) >> $server" -perc (($i / $E)*100) -Status "Processing...."

    
    try{
        $group="$($server) Admin Global Group - ca.com"

        $Sheet.Cells.Item($row,$col) = $server
	    $col++
        $Sheet.Cells.Item($row,$col) = $group
        $col++
	
        $memberList=Get-ADGroupMember "$($group)" -Recursive|select name
         
        if($memberList -ne $null){
	  	        
            $memberList=$memberList.name            
            
            $list=@()
            
            foreach($member in $memberList){
      
                $list="$($list)$($member);"
            }

            $Sheet.Cells.Item($row,$col) = $list
            $col++
        }
        else{
            $Sheet.Cells.Item($row,$col) = "Empty"
         }

    $row++

    }
    catch{
            $Sheet.Cells.Item($row,$col) = "No AD Group"
            $row++
    }
     
   }  
 }
}


Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="