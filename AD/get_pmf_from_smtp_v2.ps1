#pre requesite : exchange snapin

if (-not (Get-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010  -ErrorAction SilentlyContinue)) {
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 
    Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support                                                                                                             
}
 
    
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

$smtpList= get-content C:\temp\smtpList.txt


foreach ($smtp in $smtpList)
{

    $samName =Get-User -Filter {(WindowsEmailAddress -like $smtp) -or (UserPrincipalName -like $smtp)} -ResultSize unlimited | select SamAccountName

    if($samName -eq $null){

            $userName=$smtp.Split('.@')
            $FirstName=$userName[0]
            $LastName="$($userName[1])*"

            $NameList = Get-User -Filter {(LastName -like $LastName) -or (FirstName -like $FirstName)} -ResultSize unlimited | select SamAccountName

            if($NameList.count -ne 0){

            #$Name= $NameList

                foreach ($Name in $NameList)
                 {
                    $checkCount=0

                    $Name=$Name.SamAccountName
                    $user=Get-ADUser $Name -Properties proxyAddresses,SamAccountName | select samAccountName,proxyAddresses

                        foreach ($address in $user.proxyAddresses)
                        {
                                if (($address.Length -gt 5) -and ($address.SubString(0,5) -eq 'SMTP:'))
                                {
                                    if($address.SubString(5) -like $smtp){

                                        $Sheet.Cells.Item($row,1)  = $smtp
                                        $Sheet.Cells.Item($row,2)  = $user.samAccountName

                                    
                                        break
                        
                                     }
                                    
                                }
                        }
                
                }

                $checkCount=0


            }
            else{
            $Sheet.Cells.Item($row,1)  = $smtp
            $Sheet.Cells.Item($row,2)  = "not found"
            }
    }
         
    else{
            $Sheet.Cells.Item($row,1)  = $smtp
            $Sheet.Cells.Item($row,2)  = $samName.SamAccountName
        }
        
        $row++  
}

$Sheet.UsedRange.EntireColumn.AutoFit()