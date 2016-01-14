##################################################################################
<#
.SYNOPSIS 
    List of Group Members of Multiple AD Groups

.DESCRIPTION
    This Script Retrives the Name,DisplayName,manager,city,region of all AD Groups in different Sheets in an excel

.NOTES
   Excel and AD Module is required to run this Script
  
.Input
    Input File should be saved in c:\temp\groups.txt
    
    Input should be in this format Example:
    GIS-2ndLineVMwareSupport
    GIS-3rdLineVMwareSupport
    GIS-EngineeringVMwareSupport
    GIS-USFieldSupport
    GIS-NOCSupport
    GIS-ReadOnly
     
.Output
    Output File will be saved in C:\Temp\Group_Members_ followed by current timestamp

    AUTHOR: SALMO07
    Updated On: 28th Oct,2015
    Developed on Powershell Version 4
#>
##################################################################################

Write-Host "================================================"
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""

#If you want the Recursive members, make it $Recursive=$True otherwise make it $Recursive=$False
#$Recursive=$True

$Recursive=$False

#Input File
$InputFile="c:\temp\groups.txt"

#Current Date
$Date = $(get-date -f "yyyy-MM-dd_HH-mm-ss")     

#Output File
$OutputFile = "C:\Temp\Group_Members_$Date.xlsx"

#Excel Object
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$ExcelWordBook= $Excel.Workbooks.Add()

#AD module Check
If(-not(Get-Module -Name ActiveDirectory))
{
    Import-Module -Name ActiveDirectory
} 
 
If(-not(Get-Module -Name ActiveDirectory)){
    
    write-host "You Need AD Module to Run this Script" -foregroundcolor Red
    
}else{
    
    if(Test-Path $InputFile){
    
        $i=0

        Get-Content $InputFile|%{
    
            $group=$_
            
            $group=$group.Trim()

            Write-Host "--------------------------------------------"
            Write-Host "Processing $group"
            Write-Host "--------------------------------------------"

            $i++
        
            $Sheet = $ExcelWordBook.Worksheets.Item(1)
    
            try{                
                $sheet.Name = $group            
            }catch{
                $sheet.Name = "Sheet$i"
            }

            $row = 1
            $Column = 1
            $Sheet.Cells.Item($row,$column)= $group

            $range = $Sheet.Range("a1","s2")
            $range.Merge() | Out-Null
            $range.VerticalAlignment = -4160

            #Give it a nice Style so it stands out
            $range.Style = 'Title'

            #Increment row for next set of data
            $row++;$row++

            $Sheet.Cells.Item($row,1)  ="PMF Key"
            $Sheet.Cells.Item($row,2)  ="Display Name"
            $Sheet.Cells.Item($row,3)  ="Manager"
            $Sheet.Cells.Item($row,4)  ="city"
            $Sheet.Cells.Item($row,5)  ="region"
            #$Sheet.Cells.Item($row,6)  ="ObjectClass"

            #$group="network-isl"

            $row++
            $groupCheck_samaccountName=$null
            
            try{
                $groupCheck_samaccountName=Get-ADGroup -Filter{(name -eq $group) -or (SamAccountName -eq $group)} -Properties Name -SearchBase "DC=ca,DC=Com" | Select-Object -ExpandProperty samaccountName            
                #$groupCheck_samaccountName=Get-ADGroup $group
            }catch{
                $groupCheck_samaccountName=$null
            }


            if(($groupCheck_samaccountName -ne $Null) -and ($($groupCheck_samaccountName.count) -eq 1)){

                if($Recursive){
                
                    $memberList=Get-ADGroupMember "$($groupCheck_samaccountName)" -Recursive|select -ExpandProperty samaccountname
                }else{
                
                    $memberList=Get-ADGroupMember "$($groupCheck_samaccountName)" |select -ExpandProperty samaccountname
                }

                if($memberList -ne $null){

                    foreach($member in $memberList){

                        $Sheet.Cells.Item($row,1) = $member

                        if($member -like "SG-*"){
                            $member=$member.Substring(3)            
                        }
            
                        $UserCheck=Get-ADObject -LDAPFilter samaccountname=$member -SearchBase "dc=ca,dc=com"|select Name,ObjectClass

                        #$Sheet.Cells.Item($row,6) = $($UserCheck.ObjectClass)

                        if($UserCheck.ObjectClass -eq "User"){

                            $User=Get-ADUser $member -Properties displayname,manager,city,region|select displayname,@{l="Umanager";e={(($_.manager -split ",")[0] -split "=")[1]}},city,region

                            $Sheet.Cells.Item($row,2) = $User.displayname
                            $Sheet.Cells.Item($row,4) = $User.city
                            $Sheet.Cells.Item($row,5) = $User.region

                            if($User.Umanager -ne $null){

                                $manager=$null
                                $manager=Get-ADUser $($User.Umanager) -Properties displayname|select displayname
                                $Sheet.Cells.Item($row,3) = $manager.displayname
                            }

                        }else{
                            $Sheet.Cells.Item($row,6) = $($UserCheck.ObjectClass)
            
                        }
                    $row++
                    }
                }

            }else{
            
                $Sheet.Cells.Item($row,1) = "Group Not Found"

                write-host "$group Group is not found" -ForegroundColor Red

            }

            $Sheet.UsedRange.Columns.Autofit() | Out-Null
            $Sheet.UsedRange.Rows.Autofit() | Out-Null

            if($i -ne $($grouplist.Count)){
                $ExcelWordBook.WorkSheets.Add()| Out-Null
            }
        }

        $ExcelWordBook.SaveAs($OutputFile)
        $ExcelWordBook.Close()
        $Excel.Quit()

    }else{
        
        Write-Host ""
        Write-Host "Input file Not found in the following path $($InputFile)" -ForegroundColor Red
        Write-Host ""
    }
}
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="