

Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Import-Module ActiveDirectory

$Date = $(get-date -f "yyyy-MM-dd_HH-mm-ss")     

#$path = "C:\Users\salmo07\Desktop\AD\output_$Date.xlsx"
$path = "C:\temp\AD_Privileged_Accounts_withoutRecursion_$Date.xlsx"

$Excel1 = New-Object -ComObject Excel.Application
$Excel1.visible = $True
$Excel = $Excel1.Workbooks.Add()

#$grouplist="Account Operators","Backup Operators","Server Operators","Administrators","Group Policy Creator Owners","Intel L2","Schema Admins","Enterprise Admins","Domain Admins"
#$grouplist="Account Operators","Backup Operators","Server Operators","Administrators","Group Policy Creator Owners","Intel L2","Schema Admins","Enterprise Admins","Domain Admins","gis-admin-support"

$groupList="VCenter-Admins-USILES142","VCenter-Read-Only-USILES142","VCenter-VM-Power-Users-USILES142","vCenter-VM-Power-Users-USILES146","vCenter-Read-Only-USILES146","vCenter-Admins-USILES146","VCenter-Admins-International","VCenter-VM-Power-Users-International","VCenter-ReadOnly-International","VCenter-ITCView-PowerUsers","VCenter-ITCView-Admins","GCC-VM-REBOOT Admin Global Group - ca.com"

$count=($grouplist.count)

$i=0


foreach($group in $grouplist){
    
    $i++
    $group
    $Sheet = $Excel.Worksheets.Item(1)
    
    $sheet.Name = $group

    $row = 1

    $Sheet.Cells.Item($row,1)  ="PMF Key"
    $Sheet.Cells.Item($row,2)  ="DisplayName"
    $Sheet.Cells.Item($row,3)  ="Manager"

    $row++

    #$memberList=Get-ADGroupMember "$($group)" -Recursive|select samaccountname
    $memberList=Get-ADGroupMember "$($group)" |select samaccountname

    if($memberList -ne $null){

        $memberList=$memberList.samaccountname

        foreach($member in $memberList){

            $Sheet.Cells.Item($row,1) = $member

            if($member -like "SG-*"){
                $member=$member.Substring(3)            
            }

            $User=Get-ADUser $member -Properties displayname,manager|select displayname,@{l="Manager_DisplayName";e={if($_.manager -ne $null){$c=$null; $c=Get-ADUser ((($_.manager -split ",")[0] -split "=")[1]) -Properties DisplayName|select DisplayName; $c.DisplayName}}}
           
            $Sheet.Cells.Item($row,2) = $User.displayname

            $Sheet.Cells.Item($row,3) = $User.Manager_DisplayName
            
            $row++
        }
    }
    
    if($count -ne $i){
    $c=$Excel.WorkSheets.Add()
    }
    $Sheet.UsedRange.EntireColumn.AutoFit()
}

$Excel.SaveAs($Path)
$Excel.Close()
$Excel1.Quit()
return $Path

Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="