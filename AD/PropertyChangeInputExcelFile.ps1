$excel = New-Object -ComObject "Excel.Application"
$workbook = $excel.Workbooks.Open("C:\Users\salmo07\Desktop\userData.xls")
$workbook.sheets.item(1).activate()
$WorkbookTotal=$workbook.Worksheets.item(1)

$excel.Visible = $true


$rowCount = $WorkbookTotal.UsedRange.Rows.Count


for ($row = 2; $row -le $rowCount; $row++) {
$value = $WorkbookTotal.Cells.Item($row, 1)

$k=get-aduser $value.Text -Properties PasswordNotRequired | select PasswordNotRequired

if ($k.PasswordNotRequired -match "False") {
    $WorkbookTotal.Cells.Item($row,2)=$k.PasswordNotRequired
    $WorkbookTotal.Cells.Item($row,3)="already updated"
  }
  else{
    get-aduser $value.Text -Properties PasswordNotRequired | set-aduser -PasswordNotRequired $false 
    
    $check=get-aduser $value.Text -Properties PasswordNotRequired | select PasswordNotRequired
       
            if ($check.PasswordNotRequired -match "False") {
                $WorkbookTotal.Cells.Item($row,2)=$check.PasswordNotRequired
                $WorkbookTotal.Cells.Item($row,3)="modified now"
            }else{
            $WorkbookTotal.Cells.Item($row,3)="cannot modify"
            $WorkbookTotal.Cells.Item($row,2)=$check.PasswordNotRequired
               }
  
  }
  
}

$workbook.Close()
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)


