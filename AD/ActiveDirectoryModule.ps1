Try {

 If(-not(Get-Module -Name "ActiveDirectory")){

  Import-Module -Name ActiveDirectory

 }

} Catch {

 Write-Warning "Failed to Import REQUIRED Active Directory Module...exiting script!”

 Write-Warning "`nhttp://technet.microsoft.com/en-us/library/ee617195.aspx"

 Break

}