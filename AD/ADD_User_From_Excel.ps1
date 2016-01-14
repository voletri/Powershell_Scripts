clear
$erroractionpreference = “SilentlyContinue”

$excel1 = New-Object -ComObject "Excel.Application"

$workbook = $excel1.Workbooks.Open("C:\Users\salmo07\Desktop\rtc.xlsx")


$workbook.sheets.item(1).activate()
$WorkbookTotal=$workbook.Worksheets.item(1)

$excel1.Visible = $true


$rowCount = $WorkbookTotal.UsedRange.Rows.Count

$WorkbookTotal.Cells.Item(1,9)="Distributed List Group Name"


for ($row = 2; $row -le $rowCount; $row++) {

$serverName = $WorkbookTotal.Cells.Item($row, 2).Text
$UserName= $WorkbookTotal.Cells.Item($row,7).Text

$ccm1="https://cscrjts001.ca.com/ccm"
$ccm2="https://cscrrtc002.ca.com/ccm"
$ccm3="https://cscrrtc003.ca.com/ccm"
$ccm4="https://jazz01.ca.com/ccm04"
$ccm5="https://jazz01.ca.com/ccm05"


 If ($serverName -eq $ccm1){

$WorkbookTotal.Cells.Item($row,9)="RTC-CCM1 Users"

#Add-DistributionGroupMember -Identity "RTC-CCM1 Users" -Member $UserName

$WorkbookTotal.Cells.Item($row,10)="Added Successfully"


}elseif ($serverName -eq $ccm2) {

$WorkbookTotal.Cells.Item($row,9)="RTC-CCM2 Users"
#Add-DistributionGroupMember -Identity "RTC-CCM2 Users" -Member $UserName

$WorkbookTotal.Cells.Item($row,10)="Added Successfully"

}
elseif ($serverName -eq $ccm3){

$WorkbookTotal.Cells.Item($row,9)="RTC-CCM3 Users"
#Add-DistributionGroupMember -Identity "RTC-CCM3 Users" -Member $UserName

$WorkbookTotal.Cells.Item($row,10)="Added Successfully"
}
elseif($serverName -eq $ccm4){

$WorkbookTotal.Cells.Item($row,9)="RTC-CCM4 Users"
#Add-DistributionGroupMember -Identity "RTC-CCM4 Users" -Member $UserName

$WorkbookTotal.Cells.Item($row,10)="Added Successfully"
}
elseif($serverName -eq $ccm5){

$WorkbookTotal.Cells.Item($row,9)="RTC-CCM5 Users"
#Add-DistributionGroupMember -Identity "RTC-CCM5 Users" -Member $UserName

$WorkbookTotal.Cells.Item($row,10)="Added Successfully"
}
else{
$WorkbookTotal.Cells.Item($row,9)="DL Not Found"

$WorkbookTotal.Cells.Item($row,10)="Unable ADD The user As the DLis Not Found"
}


}

$workbook.Close()

$excel1.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
