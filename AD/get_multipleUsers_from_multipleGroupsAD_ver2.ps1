#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'AD_Group_users'

$row = 1

$Sheet.Cells.Item($row,1)  ="Group Name"
$Sheet.Cells.Item($row,2)  ="Users List"

$row++

#$groupList= get-content C:\Temp\servers.txt

$groupList="VCenter-Admins-USILES142","VCenter-Read-Only-USILES142","VCenter-VM-Power-Users-USILES142","vCenter-VM-Power-Users-USILES146","vCenter-Read-Only-USILES146","vCenter-Admins-USILES146","VCenter-Admins-International","VCenter-VM-Power-Users-International","VCenter-ReadOnly-International","VCenter-ITCView-PowerUsers","VCenter-ITCView-Admins","GCC-VM-REBOOT Admin Global Group - ca.com"
 #>
    foreach($group in $groupList){

    $group
    $col=1
    $group=$group.Trim()
    
    try{
         $memberList=Get-ADGroupMember "$($group)" -Recursive|select name
    

        if($memberList -ne $null){

            $Sheet.Cells.Item($row,$col) = $group
            $col++
            $memberList=$memberList.name            
            $list=@()
            
            foreach($member in $memberList){
      
                $list="$($list)$($member);"
            }


            $Sheet.Cells.Item($row,$col) = $list
            $col++
        }
        else{

            $Sheet.Cells.Item($row,$col) = $group
            $col++
            $Sheet.Cells.Item($row,$col) = "Empty"
         }

    $row++

    }
    catch{
            $Sheet.Cells.Item($row,$col) = $group
            $col++
            $Sheet.Cells.Item($row,$col) = "No AD Group"
            $row++
    }
     
} 