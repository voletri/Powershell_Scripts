
Get-ADUser -filter {employeeType -notlike '$null'} -Properties SamAccountName,msRTCSIP-PrimaryUserAddress,proxyAddresses |select SamAccountName,@{Name=“SIP_Address”;Expression={$_.'msRTCSIP-PrimaryUserAddress'.SubString(4)}},@{Name=“Primary_Email_Address”;Expression={ ForEach($a in $_.proxyAddresses){
                 if (($a.Length -gt 5) -and ($a.SubString(0,5) -ceq 'SMTP:'))
                     {
                        $primary=$a.SubString(5)
                        $a.SubString(5)
                         break
                      }
            }}},@{Name=“result”;Expression={ 
            $sip=$_.'msRTCSIP-PrimaryUserAddress'.SubString(4)
            
                ForEach($a in $_.proxyAddresses){
                 if (($a.Length -gt 5) -and ($a.SubString(0,5) -ceq 'SMTP:'))
                     {
                        if($a.SubString(5) -eq $sip ){
                            "true"
                              break

                        }else{
                                "false"
                              }
                        }
                 }
               } } | export-csv C:\temp\all.csv -notypeinformation






            





            