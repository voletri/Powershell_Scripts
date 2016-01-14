#pre requesite : exchange snapin 
 
   
#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'smtp_pmf'

$row = 1

$Sheet.Cells.Item($row,1)  ="smtp_address"
$Sheet.Cells.Item($row,2)  ="pmf Key"

$row++

$NameList= get-content C:\temp\smtpList.txt


foreach ($Name in $NameList)
{

$samName =Get-User -Filter {(WindowsEmailAddress -like $Name) -or (UserPrincipalName -like $Name)} -ResultSize unlimited | select SamAccountName

    if($samName -eq $null){
            $Sheet.Cells.Item($row,1)  = $Name
            $Sheet.Cells.Item($row,2)  = "not found"
         }
    else{
            $Sheet.Cells.Item($row,1)  = $Name
            $Sheet.Cells.Item($row,2)  = $samName.SamAccountName
        }
        
        $row++  
}

$Sheet.UsedRange.EntireColumn.AutoFit()