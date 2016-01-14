
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

$NameList= get-content C:\smtpList.txt


foreach ($smtp in $NameList)
{

$userList=Get-ADUser -filter * -properties proxyAddresses,SamAccountName| select proxyAddresses,samAccountName

foreach ($user in $userList){


foreach ($address in $user.proxyAddresses)
            {
                 if (($address.Length -gt 5) -and {($address.SubString(0,5) -ceq 'SMTP:') -or ($address.SubString(0,5) -ceq 'smtp:')})
                     {
                        if($address.SubString(5) -like $smtp){

                        $Sheet.Cells.Item($row,1)  = $smtp
                        $Sheet.Cells.Item($row,2)  = $user.samAccountName
                        
                        }
                        else{
                         $Sheet.Cells.Item($row,1)  = $smtp
                         $Sheet.Cells.Item($row,2)  = "not found"
                        }
                      }
            }
            }
        
        $row++  
}

$Sheet.UsedRange.EntireColumn.AutoFit()



