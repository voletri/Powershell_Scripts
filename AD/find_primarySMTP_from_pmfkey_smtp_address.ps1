#Create a new Excel object using COM 

$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'PMF KEY'

$row = 1

$Sheet.Cells.Item($row,1)  ="pmfkey@ca.com"
$Sheet.Cells.Item($row,2)  ="primarySMTP"

$row++

$pmfkeyList=@()

$NameList = get-content C:\temp\smtp.txt

foreach ($Name in $NameList)
{

$Report=Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {UserPrincipalName -eq $Name} -Properties *|select SamAccountName,mail,UserPrincipalName


    if($Report -eq $null){
        $Sheet.Cells.Item($row,1)  = $Name

        $primary_smtp="not found"
        $Sheet.Cells.Item($row,2)  = $primary_smtp
        }
    else{
        $pmfkey=$Report.SamAccountName
        $primary_smtp=$Report.mail

        $Sheet.Cells.Item($row,1)  = $Name
        $Sheet.Cells.Item($row,2)  = $primary_smtp
        }



$row++

}

$Sheet.UsedRange.EntireColumn.AutoFit()
