#requires -version 2
#requires -module ActiveDirectory
import-module ActiveDirectory
Add-Type -assemblyname Microsoft.visualBasic
$domain = [Microsoft.VisualBasic.Interaction]::InputBox("Find Domain Admin account for what domain", "Enter Domain DNS Name", "$env:userdnsdomain")
if ($domain.Length -eq 0) {break}

$domainSID = Get-ADDomain -server $domain | Select-Object -ExpandProperty DomainSID
if ($domainSID -ne $null)
{
    Get-ADUser -server $domain -Filter "SID -eq '$domainSID-500'"
}
