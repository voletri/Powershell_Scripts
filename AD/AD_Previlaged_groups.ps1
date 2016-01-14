

Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Import-Module ActiveDirectory

#$path = "C:\Users\salmo07\Desktop\AD\AD_Privileged_Accounts_$(get-date -f "yyyy-MM-dd_HH-mm-ss").xlsx"
#$path = "C:\temp\AD_Privileged_Accounts_$Date.xlsx"

$Excel1 = New-Object -ComObject Excel.Application
$Excel1.visible = $True
$Excel = $Excel1.Workbooks.Add()

#$grouplist="Account Operators","Backup Operators","Server Operators","Administrators","Group Policy Creator Owners","Intel L2","Schema Admins","Enterprise Admins","Domain Admins"
$grouplist="network-isl","Network Read Only","Network Admins","TACACS-RWnoFW","SecOps","Infrastructure Security","TACACS - GCC - Operations","Wireless-Administrator","Wireless-Receptionist","Wireless-Security","TACACS-RW-CISCO1000V","UCS-Admin","UCS-Read-Only","UCS-Power-Users","Core Security","FW-Admin","SAP-NetscalerRO","Airwave Admin","RO-FW-Access","TACACS-F5-OPERATOR Admin Global Group - ca.com","TACACS-F5-RO Admin Global Group - ca.com","TACACS-F5-RW Admin Global Group - ca.com","AI - Middleware","AI-SAP-BASIS","CyberSecurity Level 3","GIS-LA-RW"
$count=($grouplist.count)

$i=0

foreach($group in $grouplist){
    
    $i++
    
    $Sheet = $Excel.Worksheets.Item(1)
    
    $sheet.Name = $group

    $row = 1

    $Sheet.Cells.Item($row,1)  ="PMF Key"
    $Sheet.Cells.Item($row,2)  ="DisplayName"
    $Sheet.Cells.Item($row,3)  ="Manager"

    $row++

    $memberList=Get-ADGroupMember "$($group)"|select samaccountname

    if($memberList -ne $null){

        $memberList=$memberList.samaccountname

        foreach($member in $memberList){

            $Sheet.Cells.Item($row,1) = $member

            $User=$null
            $User=Get-ADUser $member -Properties displayname,manager|select displayname,@{l="Manager_DisplayName";e={if($_.manager -ne $null){$c=$null; $c=Get-ADUser ((($_.manager -split ",")[0] -split "=")[1]) -Properties DisplayName|select DisplayName; $c.DisplayName}}}
            
            if($User -ne $null){
                $Sheet.Cells.Item($row,2) = $User.displayname
                $Sheet.Cells.Item($row,3) = $User.Manager_DisplayName
            }
            
            $row++
        }
    }
    
    if($count -ne $i){
    $c=$Excel.WorkSheets.Add()
    }
    
    $Sheet.UsedRange.EntireColumn.AutoFit()
}


Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="