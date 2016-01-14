
###############################
function test-dcServiceHealth {            
[CmdletBinding()]            
param (            
 [parameter(Position=0,            
   ValueFromPipeline=$true,             
   ValueFromPipelineByPropertyName=$true)]            
 [string]$computername=$env:COMPUTERNAME            
)            
            
PROCESS {            
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()            
if (! (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){            
  Write-Warning "Must be run as administrator"            
  return            
}            
            
"ADWS", "Dfs",  "DFSR", "DNS", "IsmServ", "kdc", "Netlogon", "NTDS", "NtFrs", "W32Time", "WinRM" |            
foreach {            
            
 Get-WmiObject -Class Win32_Service -Filter "Name = '$($_)'"-ComputerName $computername |            
 select Name, DisplayName, State,            
 @{N="DC";E={$computername}}            
}            
}            
}

function get-DomainControllerNames {            
 $dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()            
 $dom.FindAllDomainControllers() | select -ExpandProperty Name            
}

get-DomainControllerNames | test-dcServiceHealth | ft -GroupBy DC –AutoSize