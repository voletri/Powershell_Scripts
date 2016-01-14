$excel1 = New-Object -ComObject "Excel.Application"
$workbook1 = $excel1.Workbooks.Open("C:\PowershellScripts\listUsers.xls")
$workbook1.sheets.item(1).activate()
$WorkbookTotal1=$workbook1.Worksheets.item(1)

$excel1.Visible = $true

for ($row = 1; $row -le 2; $row++) {

$value1 = $WorkbookTotal1.Cells.Item($row, 1)
write-host "mouna"

write-host $value1
write-host "mounika"

}

$workbook1.Close()
$excel1.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel1)
