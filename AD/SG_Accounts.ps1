
Import-Module ActiveDirectory

$file="C:\Temp\sg_accounts_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"

$SG_Account_Status={}|select Account_Name,PMF_key,DisplayName,AccountStatus,PasswordStatus,LastLogonDate,PasswordNeverExpires
$SG_Account_Status=Get-ADUser -filter * -SearchBase "ou=SOSG Accounts,ou=Groups,dc=ca,dc=com" -Properties PasswordExpired,PasswordNeverExpires,LastLogonDate|Select @{L="Account_Name";E={$_.SAMAccountName}},@{L="PMF_key";E={($_.SAMAccountName).Substring(3)}},@{L="DisplayName";E={$c=Get-ADUser $($($_.SAMAccountName.Split('-'))[1]) -Properties DisplayName|select DisplayName;$c.DisplayName}},@{L="AccountStatus";E={if($_.Enabled){"Enabled"}else{"Disabled"}}},@{L="PasswordStatus";E={if($_.PasswordExpired){"Password_Expired"}else{"Password_Not_Expired"}}},LastLogonDate,PasswordNeverExpires
$SG_Account_Status|Export-csv $file -NoTypeInformation 

#$outputhtml = $SG_Account_Status | ConvertTo-Html -Fragment

$htmlhead="<html>
<style>
BODY{font-family: Arial; font-size: 8pt;}
H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;text-align: center;}
TD{border: 1px solid #969595; padding: 5px; text-align: center;}
td.pass{background: #B7EB83;}
td.warn{background: #FFF275;}
td.fail{background: #FF2626; color: #ffffff;}
td.info{background: #85D4FF;}
</style>
<body>
<p></p>"

$htmltail = "<p>
</body></html>"	

$htmlreport = $htmlhead + $outputhtml + $htmltail
$fromemail="System@ca.com"
#[string[]]$toemail="salmo07@ca.com"
$toemail="salmo07@ca.com"
$mailserver="mail.ca.com"
$outputemailsubject="SG Account Status"
Send-MailMessage -To $toemail -From $fromemail -SmtpServer $mailserver -Subject $outputemailsubject -Body $htmlreport -BodyAsHtml -Encoding ([System.Text.Encoding]::UTF8) -Attachments $file