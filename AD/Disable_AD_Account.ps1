import-module ActiveDirectory

$smtpFrom="salmo07@ca.com"
$smtpTo="salmo07@ca.com"
$messageSubject="Disabling Accounts"
$output="process started"
$smtpserver="mail.ca.com"
#send-mailmessage -from $smtpFrom -to $smtpTo -subject $messageSubject -body $output -smtpServer $smtpserver


$username="GMAdmin"
$password=''

$fileName="d:\DisableAccounts\disable_AD_$(get-date -f "yyyy-MM-dd@HH-mm-ss").txt"
"$($fileName) is created" | Out-File  $fileName 

$PassSec = ConvertTo-SecureString $($password)  -AsPlainText -Force

$Cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $("TANT-A01" + "\" + $username),$passSec

$UserList = Get-Content -path "d:\DisableAccounts\user.txt"
"list of users whose accounts are needed to be disabled $UserList" | Out-File  $fileName -append

foreach($User in $UserList){

$status1=Get-ADUser $User | select Enabled

if($status1.Enabled -eq "true")
{

"$User is active" | Out-File  $fileName -append

Disable-ADAccount $User -AuthType Basic -Credential $Cred

$status2 = Get-ADUser $User | select Enabled

if($status2.Enabled -eq "false")
{
"$User is Disabled" | Out-File  $fileName -append
}
else{
"Unable to disable $User" | Out-File  $fileName -append
}

}else{
"$User is already Disabled" | Out-File  $fileName -append
}

} 

$output="disable acounts $UserList"

send-mailmessage -from $smtpFrom -to $smtpTo -subject $messageSubject -body $output -smtpServer $smtpserver -Attachments $fileName



