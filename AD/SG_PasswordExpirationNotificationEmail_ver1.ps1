<#####################################################################################
.NAME: SG_PasswordExpirationNotificationEmail.ps1

.Purpose:
This Script is used to send Automatic Password Expiration Alerts to SG Accounts in AD

.Notes:
This Script requires AD Module
Output File will be saved in  C:\Temp\ file name starts with SG-PwdExpiryAlertStatus followed by current timestamp

Run the Script as .\SG_PasswordExpirationNotificationEmail.ps1
Developed on Powershell Version 4

.Author: salmo07
.Created on: 18th November 2015
.Modified on: 12th Jan 2016 (updated password expiraton calculations and execution files)
######################################################################################>


########################### Send Email Function  ########################### 

Function Send-AdminEmail ($Body){

$FromEmail="itpam@ca.com"
$ToEmail="salmo07@ca.com"

$MailServer="mail.ca.com"
$subject="Password Expiration Alert Failure"

Send-MailMessage -To $AdminEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High
}


Function Send-Email ($User){

#$ToEmail="salmo07@ca.com"
$ToEmail=$($User.Email)

$FromEmail="PasswordExpirationNotification@ca.com"

$MailServer="mail.ca.com"

# Check Number of Days to Expiry
$messageDays = $User.DaysToExpire

if (($messageDays) -ge "1")
{
$messageDays = "in " + "$($User.DaysToExpire)" + " days."
}
else
{
$messageDays = "today."
}

# Email Subject Set Here
$subject="Your SG Account password will expire $messageDays"

# Email Body Set Here, Note You can use HTML, including Images.
$body ="
<div STYLE='font-family: Century Gothic; font-size: 14px; color: black'>

<p><span style='text-decoration: underline;'>This is an automatically generated Email, Please don't reply to this email, This mailbox is not monitored</span></p>

<p>Dear <strong>$($User.GivenName)</strong> </p>

<p>This is to inform you, that your SG Account <strong>$($User.Name)</strong> password will expire <strong> $messageDays &nbsp;</strong> ( <strong>$($($User.ExpiringDate).DateTime) &nbsp;EST</strong>)</p>
<p>Your SG Account Password was last changed on <strong>$($($User.PasswordLastSet).DateTime) </strong>. &nbsp;EST</p>
<p><strong><span style='text-decoration: underline;'>Password Rest Process</span></strong></p>
<ul>
<li><strong>Desktop/Laptop</strong> need to be connected to CA Network with LAN and Login with your SG Account and <br>change the password using built-in windows feature <strong>(Use ctrl-alt-del and select change password)</strong>.</li>
</ul>

<p>If you have problems changing your SG Account password, please raise a ticket by contacting GIS-Service Desk</p>
<p>&middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chat with an IT Analyst at&nbsp;<a href='http://servicedeskchat.ca.com/'>http://servicedeskchat.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Open a Service Desk ticket at&nbsp;<a href='http://servicedesk.ca.com/'>http://servicedesk.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Call the Service Desk on +1 631 342 3955, +44 1753 242223 or on x22223</p>

<p>Thank you 
</div>   
"
try{
Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High -ErrorAction Stop
}
catch{
$Body="Error Sending Email for `n $User"
Send-AdminEmail $body
}
}

######################################### Main Program #######################################################
Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$modulecheck=$true

Try {

If(-not(Get-Module -Name "ActiveDirectory")){

Import-Module -Name ActiveDirectory

}

} Catch {

$modulecheck=$false
$body="Failed to Import REQUIRED Active Directory Module...exiting script!”
Send-AdminEmail $body

Break
}

if($modulecheck){

$Userlist=Get-ADUser -filter * -SearchBase "ou=SOSG Accounts,ou=Groups,dc=ca,dc=com" -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet,"msDS-UserPasswordExpiryTimeComputed"|`
select Name,GivenName,SamaccountName,Enabled,@{L="Email";E={$($_.SamaccountName).Substring(3)+"@ca.com"}},PasswordNeverExpires,passwordexpired,PasswordLastSet,@{L="ExpiringDate";E={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},DaysToExpire,@{L="EmailNotificationStatus";E={"NotRequired"}}


foreach($User in $Userlist){

try{

$User.DaysToExpire = (New-TimeSpan -Start (get-date) -End $($User.ExpiringDate)).Days

#Email will be sent when the days remaining for password expiration is equal to 7,5 and lessthan 3

if (($($User.DaysToExpire) -ge "0") -and (($($User.DaysToExpire) -le 3) -or ($($User.DaysToExpire) -eq 7) -and $($($User.Enabled) -eq "True") -and $($($User.PasswordNeverExpires) -eq $false) -and $($($User.passwordexpired) -eq $false)))
{ 
$User.EmailNotificationStatus="Sent"       
Send-Email $User 
}       
}
Catch{          

$User.DaysToExpire="Error Occured" 
$User.EmailNotificationStatus="Error"       

$body="Error Occured while processing $User”
Send-AdminEmail $body     
}         
}

#$Userlist|export-csv "c:\temp\SG-PwdExpiry_$(get-date -f 'yyyy-MM-dd_HH-mm-ss').csv" -NoTypeInformation
$Userlist|export-csv "SG-PwdExpiry_$(get-date -f 'yyyy-MM-dd_HH-mm-ss').csv" -NoTypeInformation
}

Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "===============================================================================" 