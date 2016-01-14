
<#
.NAME: Get-SG_Account-Report.ps1

.Purpose:
    This Script Retrieves all the SG Accounts in SG Accounts OU and retrieves AccountStatus,PasswordStatus,LastLogonDate,PasswordNeverExpires

.Notes:
    Output File will be generated in "C:\Temp\"
    IF the DispalName is empty that means the associated PMF Account no longer exists in AD
    
    Run the Script as .\Get-SG_Account-Report.ps1

.Author: salmo07

.Created Date: July 7th 2015
.Modified Date: 7th Aug 2015

#>

#SG Account Status
$SG_Account_Status={}|select Account_Name,PMF_key,DisplayName,AccountStatus,PasswordStatus,LastLogonDate,PasswordNeverExpires
$SG_Account_Status=Get-ADUser -filter * -SearchBase "ou=SOSG Accounts,ou=Groups,dc=ca,dc=com" -Properties PasswordExpired,PasswordNeverExpires,LastLogonDate|Select @{L="Account_Name";E={$_.SAMAccountName}},@{L="PMF_key";E={($_.SAMAccountName).Substring(3)}},@{L="DisplayName";E={$c=Get-ADUser $($($_.SAMAccountName.Split('-'))[1]) -Properties DisplayName|select DisplayName;$c.DisplayName}},@{L="AccountStatus";E={if($_.Enabled){"Enabled"}else{"Disabled"}}},@{L="PasswordStatus";E={if($_.PasswordExpired){"Password_Expired"}else{"Password_Not_Expired"}}},LastLogonDate,PasswordNeverExpires
$SG_Account_Status|Export-csv C:\Temp\sg_accounts_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation 

