#### Spreadsheet Location########
$erroractionpreference = “SilentlyContinue” 

 $DirectoryToSaveTo = "c:\PowershellScripts\"
 $date=Get-Date -format "yyyy-MM-d"
 $Filename="pmfKey-$($date)"
 
 # before we do anything else, are we likely to be able to save the file?
# if the directory doesn't exist, then create it
if (!(Test-Path -path "$DirectoryToSaveTo")) #create it if not existing
  {
  New-Item "$DirectoryToSaveTo" -type directory | out-null
  }


  
#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

$sheet.Name = 'smtp_sip'


$row = 1

$Sheet.Cells.Item($row,1)  ="pmf Key"
$Sheet.Cells.Item($row,2)  ="smtp_address"
$Sheet.Cells.Item($row,3)  ="SIP_address"

$row++

Write-Host "started to count"

$NameList= get-content C:\Users\salmo07\Desktop\output\GroupNamesList.txt


foreach ($Name in $NameList)
{

$user = Get-ADUser -Identity $Name -Properties * | select msRTCSIP-PrimaryUserAddress,proxyAddresses

    if($user -eq $null){

        $primarySMTPAddress="not found"
        $sip="not found"

        }
    else{
      
         $primarySMTPAddress = "<Unknown>"

         foreach ($address in $user.proxyAddresses)
            {
                 if (($address.Length -gt 5) -and ($address.SubString(0,5) -ceq 'SMTP:'))
                     {
                        $primarySMTPAddress = $address.SubString(5)
                         break
                      }
            }
        $sip = $user.'msRTCSIP-PrimaryUserAddress'
        $sip = $sip.Substring(4)
         
        }

        $Sheet.Cells.Item($row,1)  = $Name
        $Sheet.Cells.Item($row,2)  = $primarySMTPAddress
        $Sheet.Cells.Item($row,3)  = $sip

        $row++
       

}

$Sheet.UsedRange.EntireColumn.AutoFit()


$filename = "$DirectoryToSaveTo$filename.xlsx"
if (test-path $filename ) { rm $filename } #delete the file if it already exists
$Sheet.UsedRange.EntireColumn.AutoFit()
$Excel.SaveAs($filename, $xlOpenXMLWorkbook) #save as an XML Workbook (xslx)
$Excel.Saved = $True
