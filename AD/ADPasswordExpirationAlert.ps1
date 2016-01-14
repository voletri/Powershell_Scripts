<#####################################################################################
.NAME: 

.Purpose:

.Author: salmo07
.Created: 
######################################################################################>


########################### Send Email Function  ########################### 
Function Send-Email ($user){
 
    $ToEmail="salmo07@ca.com"
    $FromEmail="salmo07@ca.com"

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
    $body ="<div STYLE='font-family: Century Gothic; 
font-size: 14px; color: black'>

    <p><span style='text-decoration: underline;'>This is an automatically generated message from the Active Directory System</span></p>
<p>Dear <strong>$($User.GivenName)</strong> </p>
<p>This is to inform you, that your AD SG account <strong>$($User.Name)</strong> password will expire <strong> $messageDays &nbsp;</strong> ( <strong>$("{0:D}" -f $User.ExpiringDate) &nbsp;UTC</strong>)</p>
<p>Your AD SG Account Password was last changed on <strong>$("{0:D}" -f $User.PasswordLastSet)&nbsp;UTC</strong>. &nbsp;</p>
<p><strong><span style='text-decoration: underline;'>Password Rest Process</span></strong></p>
<ul>
    <li><strong>Desktop/Laptop</strong> need to be connected to CA Network and Login with your SG account and change the password using built-in windows feature (Use ctrl-alt-del and select change password).</li>
</ul>
<p><strong><span style='text-decoration: underline;'>Your password should meet the following conditions.</span></strong></p>
<ul>
    <li>Your password must contain a minimum of 8 characters</li>
    <li>Password must be a combination of upper and lower case characters, numerals (0 - 9) and non-alphabetic characters (!,$,%,&amp;,@..)</li>
    <li>Your password must not contain part of the account or your proper name</li>
    <li>The system will not accept your previous 24 passwords</li>
    <li>Please change your password every 90 days.</li>
</ul>
<p>If you have problems changing your SG AD account password please raise a ticket by contacting GIS-Service Desk</p>
<p>&middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chat with an IT Analyst at&nbsp;<a href='http://servicedeskchat.ca.com/'>http://servicedeskchat.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Open a Service Desk ticket at&nbsp;<a href='http://servicedesk.ca.com/'>http://servicedesk.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Call the Service Desk on +1 631 342 3955, +44 1753 242223 or on x22223</p>
<p>Thank you,
</br>
Active Directory Support Team&nbsp;</p>
 </div>   
"
    Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High
}


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
 Write-Warning "Failed to Import REQUIRED Active Directory Module...exiting script!”

 Break

}

if($modulecheck){

    $Userlist=Get-ADUser -filter * -SearchBase "ou=SOSG Accounts,ou=Groups,dc=ca,dc=com" -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet|where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }|select Name,GivenName,SamaccountName,PasswordLastSet,DaysToExpire,Email,ExpiringDate
    $DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

    $User=Get-ADUser "sg-salmo07" -properties Name,PasswordNeverExpires, PasswordExpired, PasswordLastSet|select Name,GivenName,SamaccountName,PasswordLastSet,DaysToExpire,Email

    foreach ($user in $Userlist)
    {
        $passwordSetDate = $user.PasswordLastSet
  
        $User.Email=$($user.SamaccountName).Substring(3)+"@ca.com"
        
        $User.ExpiringDate = $passwordsetdate + $DefaultmaxPasswordAge
        $User.DaysToExpire = (New-TimeSpan -Start (get-date) -End $($User.ExpiringDate)).Days
        
        #Email will be sent when the days remaining for password expiration is equal to 7,10 and lessthan 3

        if (($($User.DaysToExpire) -ge "0") -and (($($User.DaysToExpire) -lt 3) -or ($($User.DaysToExpire) -eq 7) -or ($($User.DaysToExpire) -le 15)))
        {        
            Send-Email $User 
        } 
    
    }

    $Userlist|export-csv C:\Temp\pwdexpire.csv -NoTypeInformation
}


Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="