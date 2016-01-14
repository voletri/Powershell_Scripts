
#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'users_ADGroup'

$row = 1

$Sheet.Cells.Item($row,1)  ="pmfkey"
$Sheet.Cells.Item($row,2)  ="check for VMWareViewUsers"

$row++

$NameList= get-content C:\Temp\userList.txt


foreach ($userName in $NameList)
{
    $groupList=$null

    $groupList = (Get-ADUser $userName -Properties memberof).memberof

    if($groupList -ne $null){
    
    foreach($group in $groupList){

            $check="false"

            $groupDetails=Get-ADGroup $group
 
                if($groupDetails.Name -eq "VMWareViewUsers"){

                   $check="true"

                   $Sheet.Cells.Item($row,1)  = $userName
                   $Sheet.Cells.Item($row,2)  = "true"
                   break;

                   }
                
        }

    if($check -ne "true"){

        $Sheet.Cells.Item($row,1)  = $userName
        $Sheet.Cells.Item($row,2)  = "false"

    }

    }

    else{
        $Sheet.Cells.Item($row,1)  = $userName
        $Sheet.Cells.Item($row,2)  = "user doesn't exist"
    }
        
$row++  
}

$Sheet.UsedRange.EntireColumn.AutoFit()

