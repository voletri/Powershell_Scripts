
<#####################################################################################
.NAME: MAC_User_AD_PasswordExpirationNotificationEmail.ps1

.Purpose:
    This Script is used to send Automatic Password Expiration Alerts to MAC AD Users

.Notes:
    This Script requires AD Module

    Output File will be saved in  C:\Temp\  file name starts with MAC_User_AD-PwdExpiry followed by current timestamp
    
    Run the Script as .\MAC_User_AD_PasswordExpirationNotificationEmail.ps1
    Developed on Powershell Version 4

.Author: salmo07
.Created on: 14th December 2015
######################################################################################>

#Function to SendEmails to Admin
Function Send-AdminEmail ($Body){
    
    $FromEmail="itpam@ca.com"
    $ToEmail="salmo07@ca.com"
    
    $MailServer="mail.ca.com"
    $subject="MAC Password Expiration Alert Failure"
  
    Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High
}

#Function to SendEmails to Users
Function Send-Email ($User){
    
    $ToEmail="salmo07@ca.com"
    #$ToEmail=$($User.mail)

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
    $subject="Your Domain Account password will expire $messageDays"
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
        <div STYLE='font-family: Century Gothic; font-size: 14px; color: black'>

            <p><em><span style='text-decoration: underline;font-size: 10.0pt;'>This is an automatically generated Email,&nbsp; Please don't reply to this email</span></em></p>
            
            <p>Dear <strong>$($User.GivenName)</strong> </p>
        
            <p>This is to inform you, that your Domain Account <strong>$($User.SamaccountName)</strong> password will expire <strong> $messageDays &nbsp;</strong> ( <strong>$($($User.ExpiringDate).DateTime) &nbsp;EST</strong>)</p>
            <p>Your Domain Account Password was last changed on <strong>$($($User.PasswordLastSet).DateTime)&nbsp;EST</strong>. &nbsp;</p>
            <p><strong><span style='text-decoration: underline;'>Password Rest Process</span></strong></p>
            <ul>

                <li>Please use the <a href='http://ezpassword.ca.com'>ezpassword.ca.com </a> &nbsp;url to reset your CA Domain Account Password<br />
                    Note: You need to complete the Self registration process using IDM --&gt; <a href='http://idm.ca.com'>idm.ca.com </a>&nbsp;(Under Self registration tab, set the security questions), This is a one time activity&nbsp;</li>

                <strong> OR  </strong> 

                <li>You can reset the Password by following the standard Procedure, please find the reference documents at <a href='https://caone.sharepoint.com/sites/it/mac/_layouts/15/start.aspx#/SitePages/Home.aspx'> it.ca.com </a>&nbsp; </li>

            </ul>
            
            <p>If you have problems changing your Domain Account password, please raise a ticket by contacting GIS-Service Desk</p>
            <p>&middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chat with an IT Analyst at&nbsp;<a href='http://servicedeskchat.ca.com/'>http://servicedeskchat.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Open a Service Desk ticket at&nbsp;<a href='http://servicedesk.ca.com/'>http://servicedesk.ca.com</a>&nbsp;&nbsp;or<br /> &middot;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Call the Service Desk on +1 631 342 3955, +44 1753 242223 or on x22223</p>
            
            <p>Thank you 
        </div>   
    "
    #$AttachmentsFiles="C:\temp\CA Simplify Mac User Installation Documentation.pdf","C:\temp\Change Domain Password User Guide.pdf"

    try{
        #Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High -ErrorAction Stop -Attachments $AttachmentsFiles

        Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High -ErrorAction Stop
    }
    catch{
        $Body="Error Sending Email for `n $User $($Error[0])"
        Send-AdminEmail $body
    }
}

######################################### Main Program #######################################################

Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green


#AD Module Check
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

<#
    $MAC_AD_Computerlist=Get-ADComputer -filter {OperatingSystem -eq "Mac OS X"} -Properties Name,OperatingSystem,PasswordLastSet|`
    select @{l="ComputerName";e={$_.Name}},OperatingSystem,PasswordLastSet,@{L="OU";E={Get-OU $($_.DistinguishedName)}},@{l="Owner";e={(($_.name -split "mac")[0]).TrimEnd('-')}}|`
    select ComputerName,OperatingSystem,PasswordLastSet,OU,Owner,@{l="OwnerADCheck";e={$ownerName=$null;try{get-aduser $_.Owner|Out-Null;"User Exists"}catch{"User Not Found"}}}
#>

    # AD MAC Computer List
    $MAC_AD_Computerlist=Get-ADComputer -filter {OperatingSystem -eq "Mac OS X"} -Properties Name,OperatingSystem,PasswordLastSet|`
    select @{l="ComputerName";e={$_.Name}},PasswordLastSet,@{l="Owner";e={(($_.name -split "mac")[0]).TrimEnd('-')}}|`
    select ComputerName,OperatingSystem,PasswordLastSet,OU,Owner,@{l="OwnerADCheck";e={$ownerName=$null;try{get-aduser $_.Owner|Out-Null;"User Exists"}catch{"User Not Found"}}}

    # AD MAC User List
    $MAC_Userlist=$MAC_AD_Computerlist|where{$_.OwnerADCheck -eq "User Exists"}|select -ExpandProperty Owner -Unique 

    #$MAC_Userlist|out-file c:\temp\macUserlist.csv

    #Default Password Expiration
    $DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

    #Fetches Users Password Expiration Details
    $MAC_Userlist_Data=$MAC_Userlist|%{

        Get-ADUser $_ -properties PasswordNeverExpires, PasswordExpired, PasswordLastSet,mail|where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }|`
        select GivenName,SamaccountName,PasswordLastSet,mail,@{l="ExpiringDate";e={$($_.PasswordLastSet) + $DefaultmaxPasswordAge}},DaysToExpire
    }


    #Itertaes on each User
    foreach($User in $MAC_Userlist_Data){

<#
    $User= Get-ADUser "salmo07" -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet,mail,title|where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }|`
        select Name,GivenName,SamaccountName,PasswordLastSet,mail,@{l="ExpiringDate";e={$($_.PasswordLastSet) + $DefaultmaxPasswordAge}},DaysToExpire,title
#>
    
        try{
             
            $User.DaysToExpire = (New-TimeSpan -Start (get-date) -End $($User.ExpiringDate)).Days
        
            #Email will be sent when the days remaining for password expiration is equal to 14,7,5 and lessthan 3

            if (($($User.DaysToExpire) -ge "0") -and (($($User.DaysToExpire) -lt 3) -or ($($User.DaysToExpire) -eq 7) -or ($($User.DaysToExpire) -eq 14)))
            {        
                #Sends Email
                Send-Email $User 
            }       
        }
        Catch{          
                        
            $body="Error Occured while processing $User... $($error[0])”
            Send-AdminEmail $body     
        }         
    }

   #Exports the Userlist Details 

   #$MAC_Userlist_Data|export-csv "c:\temp\MAC_User_AD-PwdExpiry_$(get-date -f 'yyyy-MM-dd_HH-mm-ss').csv" -NoTypeInformation
   $MAC_Userlist_Data|export-csv "MAC_User_AD-PwdExpiry_$(get-date -f 'yyyy-MM-dd_HH-mm-ss').csv" -NoTypeInformation

}
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "===============================================================================" 
    