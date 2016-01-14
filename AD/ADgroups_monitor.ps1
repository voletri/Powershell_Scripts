#requires -version 2.0 
 
# ############################################################################# 
# NAME: TOOL-Monitor-AD_DomainAdmins_EnterpriseAdmins.ps1 
#  
# AUTHOR:  Francois-Xavier CAT 
# DATE:  2012/02/01 
# EMAIL: info@lazywinadmin.com 
#  
# COMMENT:  This script is monitoring group(s) in Active Directory and send an email when  
#     someone is added or removed 
# 
# REQUIRES:  
#  -Quest AD Snapin 
#  -A Scheduled Task 
# 
# VERSION HISTORY 
# 1.0 2012.02.01 Initial Version. 
# 1.1 2012.03.13 CHANGE to monitor both Domain Admins and Enterprise Admins
# 1.2 2013.09.23 FIX issue when specifying group with domain 'DOMAIN\Group'
#                CHANGE Script Format (BEGIN, PROCESS, END)
#                ADD Minimal Error handling. (TRY CATCH)
# 
# ############################################################################# 
   
 
BEGIN {
    #TRY{
        # Monitor the following groups 
        $Groups =  "Domain Admins","Enterprise Admins"
 
        # The report is saved locally 
        $ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path) 
        $DateFormat = Get-Date -Format "yyyyMMdd_HHmmss"
 
        # Email information
        $Emailfrom   = "salmo07@ca.com"
        $Emailto   = "salmo07@ca.com"
        $EmailServer  = "mail.ca.com"      
}
 
PROCESS{
 
    TRY{
        FOREACH ($item in $Groups){
 
            # Let's get the Current Membership
            $GroupName = Get-adgroup $item
            $Members = Get-ADGroupMember $item | Select-Object Name, SamAccountName, DN 
            $EmailSubject = "PS MONITORING - $GroupName Membership Change"
    
            # Store the group membership in this file 
            $StateFile = "$($GroupName.domain.name)_$($GroupName.name)-membership.csv"
    
            # If the file doesn't exist, create one
            If (!(Test-Path $StateFile)){  
                $Members | Export-csv $StateFile -NoTypeInformation
                }
    
            # Now get current membership and start comparing it to the last lot we recorded 
            # catching changes to membership (additions / removals) 
            $Changes =  Compare-Object $Members $(Import-Csv $StateFile) -Property Name, SamAccountName, DN | 
                Select-Object Name, SamAccountName, DN,
                    @{n='State';e={
                        If ($_.SideIndicator -eq "=>"){
                            "Removed" } Else { "Added" }
                        }
                    }
   
            # If we have some changes, mail them to $Email 
            If ($Changes) {  
                $body = $($Changes | Format-List | Out-String) 
                $smtp = new-object Net.Mail.SmtpClient($EmailServer) 
                $smtp.Send($emailFrom, $emailTo, $EmailSubject, $body) 
                } 
            #Save current state to the csv 
            $Members | Export-csv $StateFile -NoTypeInformation -Encoding Unicode
        }
    }
    CATCH{Write-Warning "PROCESS BLOCK - Something went wrong"}
 
}#PROCESS
END{"Script Completed"}
 

#end region script