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
$Excel_Cell.Cells.Item(1,2) = “PasswordLastSet”
$Excel_Cell.Cells.Item(1,3) = “PasswordNeverExpires”


$d = $Excel_Cell.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$d.EntireColumn.AutoFit($True)

$intRow = 2
$List = get-content C:\Users\salmo07\Desktop\user.txt


foreach ($Name in $List)
{
$properties=get-aduser $Name -Properties * |Select-Object Name,PasswordLastSet,PasswordNeverExpires
$Excel_Cell.Cells.Item($intRow, 1) = $properties.Name
$Excel_Cell.Cells.Item($intRow, 2) = $properties.PasswordLastSet
$Excel_Cell.Cells.Item($intRow, 3) = $properties.PasswordNeverExpires

$intRow = $intRow + 1
}


$d.EntireColumn.AutoFit()