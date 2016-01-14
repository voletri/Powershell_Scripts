
Get-ADUser -filter {employeeType -ne "*"} -Properties * |select SamAccountName,@{Name=“SIP_Address”;Expression={$_.'msRTCSIP-PrimaryUserAddress'.SubString(4)}},@{Name=“Primary_Email_Address”;Expression={ ForEach($a in $_.proxyAddresses){
                 if (($a.Length -gt 5) -and ($a.SubString(0,5) -ceq 'SMTP:'))
                     {
                        $a.SubString(5)
                         break
                      }
            }}} | export-csv C:\all.csv -notypeinformation