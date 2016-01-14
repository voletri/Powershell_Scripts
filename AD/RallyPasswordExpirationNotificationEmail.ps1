<#####################################################################################
.NAME: RallyPasswordExpirationNotificationEmail.ps1

.Purpose:
    This Script is used to send Automatic Password Expiration Alerts to AD Users in the Given List

.Notes:
    This Script requires AD Module

    Input File should be placed in  "c:\temp\RallyUserlist.txt"

    Input File Format: Example
    salmo03
    thoni9

    Output File will be saved in  C:\Temp\  file name starts with PwdExpiryAlertStatus followed by current timestamp
    
    Run the Script as .\RallyPasswordExpirationNotificationEmail.ps1
    Developed on Powershell Version 4

.Author: salmo07
.Created on: 15th october 2015
######################################################################################>


########################### Send Email Function  ########################### 
Function Send-Email ($user){
 
    $ToEmail="salmo07@ca.com"
    #$ToEmail=$($User.mail)

    $FromEmail="PasswordExpiryNotification@ca.com"

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
    $subject="Your Domain Account password will expire $messageDays"
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="<div STYLE='font-family: Century Gothic; font-size: 14px; color: black'>

    <p><span style='text-decoration: underline;'>This is an automatically generated Email, Please don't reply to this email, This mailbox is not monitored</span></p>
<p>Dear <strong>$($User.GivenName)</strong> </p>
<p>This is to inform you, that your Domain account <strong>$($User.Name)</strong> password will expire <strong> $messageDays &nbsp;</strong> ( <strong>$("{0:D}" -f $User.ExpiringDate) &nbsp;UTC</strong>)</p>
<p>Your Domain Account Password was last changed on <strong>$("{0:D}" -f $User.PasswordLastSet)&nbsp;UTC</strong>. &nbsp;</p>
<p><strong><span style='text-decoration: underline;'>Password Rest Process</span></strong></p>
<ul>
    <li><strong>Desktop/Laptop</strong> need to be connected to CA Network and Login with your domain account and change the password using built-in windows feature (Use ctrl-alt-del and select change password).</li>
</ul>
<p>If you have problems changing your Domain account password please raise a ticket by contacting GIS-Service Desk</p>
<p>&middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chat with an IT Analyst at&nbsp;<a href='http://servicedeskchat.ca.com/'>http://servicedeskchat.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Open a Service Desk ticket at&nbsp;<a href='http://servicedesk.ca.com/'>http://servicedesk.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Call the Service Desk on +1 631 342 3955, +44 1753 242223 or on x22223</p>
<p>Thank you 
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
    
    $InputFile = "c:\temp\RallyUserlist.txt"

    $Userlist= Get-Content $InputFile

    $s=@()

    foreach($u in $Userlist){
    
        $DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
        $User=$Null

        try{
            $User=Get-ADUser $u -properties Name,PasswordNeverExpires,mail,PasswordExpired, PasswordLastSet|select Name,GivenName,SamaccountName,PasswordLastSet,DaysToExpire,ExpiringDate,PasswordExpired,mail
             
            $passwordSetDate = $user.PasswordLastSet
          
            $User.ExpiringDate = $passwordsetdate + $DefaultmaxPasswordAge
            $User.DaysToExpire = (New-TimeSpan -Start (get-date) -End $($User.ExpiringDate)).Days
        
            #Email will be sent when the days remaining for password expiration is equal to 10,15 and lessthan 5

            if (($($User.DaysToExpire) -ge "0") -and (($($User.DaysToExpire) -lt 5) -or ($($User.DaysToExpire) -eq 10) -or ($($User.DaysToExpire) -eq 15)))
            {        
                Send-Email $User 
            }
        
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            $User={}|select @{l="Name";e={$u}},@{l="GivenName";e={"User Not Found"}},SamaccountName,PasswordLastSet,DaysToExpire,ExpiringDate,PasswordExpired,mail
        }     
        Catch{         
            $User={}|select @{l="Name";e={$u}},@{l="GivenName";e={"Error Occurred"}},SamaccountName,PasswordLastSet,DaysToExpire,ExpiringDate,PasswordExpired,mail                     
        } 
        
        $s+=$User
    }
    
    $s|export-csv "C:\Temp\PwdExpiryAlertStatus_$(get-date -f 'yyyy-MM-dd_HH-mm-ss').csv" -NoTypeInformation
}

Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="