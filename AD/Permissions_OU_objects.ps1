<#
.Synopsis
   Reports Permissions on OU objects.
.DESCRIPTION
    This script creates a report of all OU permissions.
.PARAMETER REPORTTYPE
Type of Report.  The default is Filtered, which are Filtered (not inherited)
write, create and delete rights.  To get a full report of all rights,
use "full"

.PARAMETER DOMAINDNSNAME
Domain to search.  If omitted, the default is the local domain

.PARAMETER ReportFile
Report file path.  If omitted, the audit log file is put on user's desktop

.PARAMETER OPENLog
If present, the CSV log will open when the script completes

.EXAMPLE
   Get List of Write, Create, Delete not inherited in the local domain.  The ReportFile will be on the desktop
   Get-OUPermissions

.EXAMPLE
  Get list of all permissions
  Get-OUPermissions -ReportType Full

.NOTES
Original script https://gallery.technet.microsoft.com/Active-Directory-OU-1d09f989/view/Discussions
by Ashley McGlone http://aka.ms/GoateePFE
Microsoft Premier Field Engineer
March 2013

Alan Kaplan moved code into an advanced function, with parameters
Works only in local domain
Changed Filtered filter, Added reporting from other domains
alan dot kaplan at va dot gov, alan at akaplan.com

Kaplan version history
November 2014
version 1.1 fixed query wildcards
version 1.2 fixed exclusion of allows
version 2.0 added other domain support
version 2.1 Renamed Assigned to Filtered, added OpenLog switch, #requires
        added regex for matches, ignorelist. 11/22/14
#>

#Requires -version 2
#Requires -Module ActiveDirectory
function Get-OUPermissions
{
    Param
    (
        # ReportType default Filtered
        [Parameter(Mandatory=$False)]
        [ValidateSet("Full", "Filtered")]
        [string]$ReportType = "Full",

        #DomainDNSName default is the user's domain
        [Parameter(Mandatory=$false)]
        [string]$DomainDNSName = ((get-addomain).dnsroot).tostring(),

        # Ignore these user or group name prefixes in reporting
        [Parameter(Mandatory=$False)]

        #You can edit this list to put strings to ignore when creating filtered list
        #$Ignore ="S-,Mydom,UserName,MyDom2\"
        [string]$Ignore,

        #ReportFile default created later to include domain name
        [Parameter(Mandatory=$false)]
        [string]$ReportFile,

        #OpenLog
        [Parameter(Mandatory=$false)]
        [switch]$OpenLog
    )

#AG
Import-Module ActiveDirectory
# This array will hold the report output.
$Script:ADReport = @()

# Build a lookup hash table that holds all of the string names of the
# ObjectType GUIDs referenced in the security descriptors.
# See the Active Directory Technical Specifications:
#  3.1.1.2.3 Attributes
#    http://msdn.microsoft.com/en-us/library/cc223202.aspx
#  3.1.1.2.3.3 Property Set
#    http://msdn.microsoft.com/en-us/library/cc223204.aspx
#  5.1.3.2.1 Control Access Rights
#    http://msdn.microsoft.com/en-us/library/cc223512.aspx
#  Working with GUID arrays
#    http://blogs.msdn.com/b/adpowershell/archive/2009/09/22/how-to-find-extended-rights-that-apply-to-a-schema-class-object.aspx
# Hide the errors for a couple duplicate hash table keys.

#AK 
if (!$ReportFile){
$ReportFile =  "$env:USERPROFILE\desktop\"+$domainDNSName.Replace(".","-")+'_AD_Permission_Audit.csv'
}

#AK
#Variation of http://blogs.technet.com/b/heyscriptingguy/archive/2011/02/18/speed-up-array-comparisons-in-powershell-with-a-runtime-regex.aspx
$Ignore = $Ignore+","+"Builtin\,NT Authority\"
$IgnoreList = $Ignore.Split(",")
[regex]$Ignorelist_regex = '(?i)^(' + (($Ignorelist |foreach {[regex]::escape($_)}) –join "|") + ')'
#$Ignorelist_regex.ToString()

$PermList = "Write,Create,All,Delete".Split(",")
[regex]$Permlist_regex = '(' + ($Permlist –join "|") + ')'
#$Permlist_regex.ToString()


#Mostly AG except the progress writes from AK and addition of -Server 

$schemaIDGUID = @{}
#AG remark ### NEED TO RECONCILE THE CONFLICTS ###

$ErrorActionPreference = 'SilentlyContinue'
Write "`nBeginning AD permission audit of $DomainDNSName`n"
Write-Host -NoNewLine "Getting Schema GUID info .... " 
Get-ADObject -SearchBase (Get-ADRootDSE -Server $DomainDNSName).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
    ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE -server $DomainDNSName).configurationNamingContext)" `
    -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
    ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
$ErrorActionPreference = 'Continue'
Write " Done.`n"

Write "Getting a list of all OUs, plus the root containers for good measure (users, computers, etc.)."
$OUs  = @(Get-ADDomain -Server $DomainDNSName | Select-Object -ExpandProperty DistinguishedName)
$OUs += Get-ADOrganizationalUnit -Server $DomainDNSName -Filter * | Select-Object -ExpandProperty DistinguishedName
$OUs += Get-ADObject -Server $DomainDNSName -SearchBase (Get-ADDomain -server $domainDNSName).DistinguishedName -SearchScope OneLevel -LDAPFilter '(objectClass=container)' | Select-Object -ExpandProperty DistinguishedName
$msg =  $msg = 'Found '+($OUs.count).ToString()+' AD containers and OUs, now collecting permissions.  This can take a while ...'
Write-Host -noNewLine $msg

# Loop through each of the OUs and retrieve their permissions.
# Add report columns to contain the OU path and string names of the ObjectTypes.
ForEach ($OU in $OUs) {
    #AK replaced Get-ACL code with next two lines to support specifying domain
    $a = Get-ADObject -Identity $OU -Server $DomainDNSName -Properties ntSecurityDescriptor
    $Script:ADReport += $a.nTSecurityDescriptor | 
    Select-Object -ExpandProperty Access | 
    Select-Object @{name='organizationalUnit';expression={$OU}}, `
                  @{name='GroupOrUser';expression={$_.IdentityReference}},
                  @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                  @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                  * -ExcludeProperty IdentityReference
}

#AK
Write "Done. `nIdentityReference property displays as `"GroupOrUser`""

switch ($ReportType)
{
    "Full" {
        write "Exporting full report"
        $Script:ADReport | Export-Csv -Path $ReportFile -NoTypeInformation
    }
    "Filtered" {
        write "Exporting filtered report with only explicitly Filtered Read, Write or Create permissions, by Group and OU"
        Write "Report does not include permissions to users or groups containing one of these strings: $Ignorelist"
        # Show only the interesting, explicitly Filtered permissions by Group and OU, filtered
        # this is much, much faster than Where-Object
        $d = foreach ($ACLItem in $Script:AdReport) {
    if (
         ($ACLItem.AccessControlType -eq "Allow") -And `
         ($ACLItem.IsInherited -eq $False) -And `
         ($ACLItem.GroupOrUser -match $Ignorelist_regex -eq $False) -And `
         ($ACLItem.ActiveDirectoryRights -match $Permlist_regex) 
       )
    {
        $ACLItem
        }
}
        $d | Select-Object -property GroupOrUser, OrganizationalUnit |
        get-unique -asString |
        Sort-Object GroupOrUser | 
        Export-Csv -Path $ReportFile -NoTypeInformation
    }
    
}
    if ($OpenLog) {
        ii $ReportFile
    }ELSE{
        Write. "Done.  Report File is $ReportFile"
    }
}

#Get the list of all OUs with permissions of users and groups who have had 
#Filtered "all" write, create or delete.  Open Log when done
Get-OUPermissions -OpenLog