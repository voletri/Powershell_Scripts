
$Date = $(get-date -f "yyyy-MM-dd_HH-mm-ss")     
$path = "C:\Temp\Group_Members_$Date.xlsx"

$Excel1 = New-Object -ComObject Excel.Application
$Excel1.visible = $True
$Excel = $Excel1.Workbooks.Add()

$grouplist="Recipient Management","Organization Management","Public Folder Management"

foreach($group in $grouplist){
    
    $Sheet = $Excel.Worksheets.Item(1)
    #$group=$grouplist |select -First 1
    $sheet.Name = $group

    $row = 1

    $Sheet.Cells.Item($row,1)  ="PMF Key"
    $Sheet.Cells.Item($row,2)  ="DisplayName"
    $Sheet.Cells.Item($row,3)  ="Manager"
    $Sheet.Cells.Item($row,4)  ="city"
    $Sheet.Cells.Item($row,5)  ="region"

    $row++

    $memberList=Get-ADGroupMember "$($group)" -Recursive|select samaccountname
    
    if($memberList -ne $null){

        $memberList=$memberList.samaccountname

        foreach($member in $memberList){

            #$member=$memberList |select -First 1
            $Sheet.Cells.Item($row,1) = $member

            $User=Get-ADUser $member -Properties displayname,manager,city,region|select displayname,@{l="Umanager";e={(($_.manager -split ",")[0] -split "=")[1]}},city,region

            $Sheet.Cells.Item($row,2) = $User.displayname
            $Sheet.Cells.Item($row,4) = $User.city
            $Sheet.Cells.Item($row,5) = $User.region

            if($User.Umanager -ne $null){

            $manager=$null
            $manager=Get-ADUser $($User.Umanager) -Properties displayname|select displayname

            $Sheet.Cells.Item($row,3) = $manager.displayname
            }
            $row++
        }

    }
    $c=$Excel.WorkSheets.Add()
}

$Excel.SaveAs($Path)
$Excel.Close()
$Excel1.Quit()