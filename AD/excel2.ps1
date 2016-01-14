
clear
$erroractionpreference = “SilentlyContinue”

#Create Excel Com Object
$Excel = New-Object -com Excel.Application

# Make the Excel Application Visible to the end user
$Excel.visible = $True

# Create a WorkBook inside the Excel application
# that we can start manipulating.
$Excel_Workbook = $Excel.Workbooks.Add()

$Excel_Cell = $Excel_Workbook.Worksheets.Item(1)
$Excel_Cell.Cells.Item(1,1) = “Name”
$Excel_Cell.Cells.Item(1,2) = “IPV4Address”
$Excel_Cell.Cells.Item(1,3) = “operating System”
$Excel_Cell.Cells.Item(1,4) = “last logon time ”
$Excel_Cell.Cells.Item(1,5) = “last login user”


$d = $Excel_Cell.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$d.EntireColumn.AutoFit($True)

$properities=Get-ADComputer -Filter * -Properties name, ipv4Address, ipv6Address, OperatingSystem , LastLogonTimeStamp 

write-host "outside for loop"

foreach($p in $properities)
{
write-host $p.name

$Excel_Cell.Cells.Item($intRow, 1) = $p.name
$Excel_Cell.Cells.Item($intRow, 2) = $p.ipv4Address
$Excel_Cell.Cells.Item($intRow, 3) = $p.OperatingSystem
$Excel_Cell.Cells.Item($intRow, 4) = $p.LastLogonTimeStamp

}







