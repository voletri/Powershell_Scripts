# Name: Join-CADomain.ps1
# Purpose: Joins the computer to the ca.com domain in the correct OU based on region
# Author: Alquin Gayle
# Changelog:
# 27-AUG-13: Created script
# v1.01:4-Sept-13: Modified the Join-Domain function to deal with lower computer names

Param($User, $Password)

# Name: Get-OU
# Purpose: Uses the prefix in $Name to determine which OU should be returned
Function Get-OU() {
Param([String]$Name)

If ($Name.ToUpper().StartsWith("INHY")) {
        $OU = "OU=ITC Servers,OU=ITC Hyderabad,DC=ca,DC=com"
    }
    ElseIf ($Name.ToUpper().StartsWith("UKSL")) {
        $OU = "OU=EMEA Servers,OU=Europe Middle East Africa,DC=ca,DC=com"
    }
    ElseIf ($Name.ToUpper().StartsWith("AUSY")) {
        $OU = "OU=APJ Servers,OU=Asia Pacific,DC=ca,DC=com"
    }
    Else {
        $OU = "OU=NA Servers,OU=North America,DC=ca,DC=com"
    }
    Return $OU
}

# Name: Join-Domain
# Purpose: Uses $DUser and $DPassword to join the local computer to $OrgUnit in AD
Function Join-Domain() {
Param([String]$DUser, [String]$DPassword, [String] $OrgUnit)

    $SecPasswd = ConvertTo-SecureString $DPassword -AsPlainText -Force
    $DCreds = New-Object System.Management.Automation.PSCredential($DUser, $SecPasswd)
    Add-Computer -DomainName ca.com -Credential $DCreds -OUPath $OrgUnit -Force -Restart
}

$ServerName = $ENV:COMPUTERNAME
$ServerOU = Get-OU $ServerName

Write-Host $ServerName
Write-Host $ServerOU

Join-Domain $User $Password $ServerOU