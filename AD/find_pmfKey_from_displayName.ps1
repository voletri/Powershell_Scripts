#Create a new Excel object using COM 

$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'PMF KEY'

$row = 1

$Sheet.Cells.Item($row,1)  ="display Name"
$Sheet.Cells.Item($row,2)  ="pmfkey"

$row++

$pmfkeyList=@()

$displayNameList = get-content C:\temp\displayname.txt

foreach ($displayName in $displayNameList)
{
$displayName=$displayName.trim();
$Report=Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {displayname -eq $displayName} |select SamAccountName

    if($Report -eq $null){

        $pmfkey="not found"
        }
    else{
        $pmfkey=$Report.SamAccountName
        }

$Sheet.Cells.Item($row,1)  = $displayName
$Sheet.Cells.Item($row,2)  = $pmfkey

$row++

}

$Sheet.UsedRange.EntireColumn.AutoFit()
