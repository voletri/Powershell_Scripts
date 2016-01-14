#Get Last Logon for All Users Across All Domain Controllers


Import-Module ActiveDirectory
 
function Get-ADUsersLastLogon()
{
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $users = Get-ADUser -Filter *
  $time = 0
  $exportFilePath = "c:\lastLogon.csv"
  $columns = "name,username,datetime"
 
  Out-File -filepath $exportFilePath -force -InputObject $columns
 
  foreach($user in $users)
  {
    foreach($dc in $dcs)
    { 
      $hostname = $dc.HostName
      $currentUser = Get-ADUser $user.SamAccountName | Get-ADObject -Server $hostname -Properties lastLogon
 
      if($currentUser.LastLogon -gt $time) 
      {
        $time = $currentUser.LastLogon
      }
    }
 
    $dt = [DateTime]::FromFileTime($time)
    $row = $user.Name+","+$user.SamAccountName+","+$dt
 
    Out-File -filepath $exportFilePath -append -noclobber -InputObject $row
 
    $time = 0
  }
}
 
Get-ADUsersLastLogon



<#that is the line where the code will attempt to query the last logon date for each user on each domain controller. Have you verified that the firewall, if enabled, is not blocking the above ports as well as 9389. 9389 is what ADWS listens on. Also, make sure the ADWS service is running. Are any lines being written to the output file at all?
#>
