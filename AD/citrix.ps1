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

#$groupList= get-content C:\temp\dlp.txt
$groupList= get-content C:\temp\citrix.txt
#$groupList=$groupList|select -First 2

foreach($group in $groupList){

    $row=1
    $group=$group.Trim()
    $memberList=$null

    $memberList=Get-ADGroupMember $group -Recursive|select name
    
    if($memberList -ne $null){

    $Sheet.Cells.Item($row,$col) = $group
    $Sheet.Cells.Item($row,$col+1) = "Country/City"
    $Sheet.Cells.Item($row,$col+2) = "Region"


    $row++

    $memberList=$memberList.name

    foreach($member in $memberList){

    $t=$null
    $t=Get-ADUser $member -properties l,region|select samaccountname,l,region
    $Sheet.Cells.Item($row,$col) = $t.samaccountname
    $Sheet.Cells.Item($row,$col+1) = $t.l
    $Sheet.Cells.Item($row,$col+2) = $t.region
    $row++
    }

    }
    else{
    $Sheet.Cells.Item($row,$col) = $group
    $row++
    $Sheet.Cells.Item($row,$col) = "Group Not found/Empty"
    }

$col++
$col++
$col++
}
