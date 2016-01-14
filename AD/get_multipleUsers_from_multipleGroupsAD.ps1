#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)


$sheet.Name = 'AD_Group_users'

$col = 1

$Sheet.Cells.Item(1,$col)  ="Group Name"
$Sheet.Cells.Item(2,$col)  ="Users List"

$col++

$groupList="DLPInScopeFinance","DLPInScopeSaaS","DLPInScopeHR","DLPInScopeLegal","DLPInScopeSupport","DLPInScopeProfServ","DLPOutOfScopeSupport","DLPOutOfScopeSaaS","DLPOutOfScopeLegal","DLPOutOfScopeProfServ","DLPOutOfScopeHR","DLPOutOfScopeFinance"


foreach($group in $groupList){

    $row=1
    $group=$group.Trim()
    $memberList=$null

    $memberList=Get-ADGroupMember $group -Recursive|select name
    
    if($memberList -ne $null){

    $Sheet.Cells.Item($row,$col) = $group

    $row++

    $memberList=$memberList.name

    foreach($member in $memberList){

    $Sheet.Cells.Item($row,$col) = $member
    $row++
    }

    }
    else{
    $Sheet.Cells.Item($row,$col) = $group
    $row++
    $Sheet.Cells.Item($row,$col) = "Group Not found/Empty"
    }

$col++
}
