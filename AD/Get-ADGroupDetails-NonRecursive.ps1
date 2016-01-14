

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
$grouplist="Account Operators","Backup Operators","Server Operators","Administrators","Group Policy Creator Owners","Intel L2","Schema Admins","Enterprise Admins","Domain Admins","gis-admin-support"

$count=($grouplist.count)

$i=0


foreach($group in $grouplist){
    
    $i++
    
    $Sheet = $Excel.Worksheets.Item(1)
    
    $sheet.Name = $group

    $row = 1

    $Sheet.Cells.Item($row,1)  ="PMF Key"
    $Sheet.Cells.Item($row,2)  ="AccountType"
    $Sheet.Cells.Item($row,3)  ="DisplayName"
    $Sheet.Cells.Item($row,4)  ="Manager"
    $Sheet.Cells.Item($row,5)  ="Password Status"

    $row++

    #$memberList=Get-ADGroupMember "$($group)" -Recursive|select samaccountname
    $memberList=Get-ADGroupMember "$($group)" |select samaccountname

    if($memberList -ne $null){

        $memberList=$memberList.samaccountname

        foreach($member in $memberList){

            $Sheet.Cells.Item($row,1) = $member

            $ADobject=$Null
            $ADobject=Get-ADObject -LDAPFilter samaccountname=$member -SearchBase "dc=ca,dc=com"|select Name,ObjectClass

            $Sheet.Cells.Item($row,2) = $ADobject.ObjectClass

            if($ADobject.ObjectClass -eq "user"){
                                                       
                 if($member -like "SG-*"){
                    $member=$member.Substring(3)            
                 }
                
                $User=$Null
                $User=Get-ADUser $member -Properties displayname,manager,title,PasswordNeverExpires|select displayname,@{l="Manager_DisplayName";e={if($_.manager -ne $null){$c=$null; $c=Get-ADUser ((($_.manager -split ",")[0] -split "=")[1]) -Properties DisplayName|select DisplayName; $c.DisplayName}}},title,PasswordNeverExpires
                
                if($User.title -eq $null){
                   $Sheet.Cells.Item($row,2) = "Generic User"               
                }

                if(!($User.PasswordNeverExpires)){
                   $Sheet.Cells.Item($row,5) = "PasswordExpires"                               
                }else{
                   $Sheet.Cells.Item($row,5) = "PasswordNeverExpires"                               
                }


                $Sheet.Cells.Item($row,3) = $User.displayname
                $Sheet.Cells.Item($row,4) = $User.Manager_DisplayName 
                          
            }elseif($ADobject.ObjectClass -eq "group"){
                
                $group=$null
                $group=Get-ADgroup $member -Properties displayname,manager|select displayname,@{l="Manager_DisplayName";e={if($_.manager -ne $null){$c=$null; $c=Get-ADUser ((($_.manager -split ",")[0] -split "=")[1]) -Properties DisplayName|select DisplayName; $c.DisplayName}}}
                $Sheet.Cells.Item($row,3) = $group.displayname
                $Sheet.Cells.Item($row,4) = $group.Manager_DisplayName           
            
            }
            
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