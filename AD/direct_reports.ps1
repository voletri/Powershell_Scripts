Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a top level user name")]
[string]$identity
)
 
Function Get-DirectReports {
[cmdletbinding()]
 
Param(
[Parameter(Position=0,ValueFromPipelineByPropertyName=$True)]
[string]$DistinguishedName,
[int]$Tab=2
)
 
Process {
 $direct = Get-ADUser -Identity $DistinguishedName -Properties DirectReports
 
 if ($direct.DirectReports) {
  $direct.DirectReports | Get-ADUser -Properties Title | foreach {
   "{0} [{1}]" -f $_.Name.padleft($_.name.length+$tab),$_.title
   $_ | Get-DirectReports -Tab $($tab+2)
  }
 }
 
} #process
 
} #end function
 
$user = Get-ADUser $Identity -Properties DirectReports,Title
$reports = $user.DirectReports
 
"{0} [{1}]" -f $User.name,$User.Title
 
foreach ($report in $reports) {
$direct = $report | Get-ADUser -Properties DirectReports,Title,Department
"{0} [{1}]" -f $direct.name.padleft($direct.name.length+1,">"),$direct.Title
$direct | Get-DirectReports
} #foreach