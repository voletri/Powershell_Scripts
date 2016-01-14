
Function Send-Email($SG_Account){

$Account=$SG_Account.Substring(3)

 $htmlhead="<html>
				<style>
				BODY{font-family: Arial; font-size: 11pt;}
				H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
				</style>
				<body>
                <p>Hi,</p>
<p>
I have created SG account for you. Please find the below details for the same:
</p>
<p>
Account Id: <b>$SG_Account</b>
</br>
Password: <b>P@55word</b>
</p>
<p>
<b>Please Reset your SG Account password, To Reset your SG Account Password follow the below steps</b></br></br>
1.Use your switch user option in your local desktop and do the reset while you are in network.<br/>
2.Enter the SG Account Id and Password as above and it will prompt for the Reset.
</p>
<p>
Let me know if you have any questions.
</p>
<p>
Regards<br>
Nikhitha
</p>"

 $htmltail = "</body></html>"	
 $htmlreport = $htmlhead + $htmltail
 
 $fromemail="thoni08@ca.com"
 $mailserver="mail.ca.com"
 $toemail="$Account@ca.com"

 $subject="SG Account Details"

 Send-MailMessage -To $toemail -From $fromemail -Cc $fromemail -SmtpServer $mailserver -Subject $subject -Body $htmlreport -BodyAsHtml -Encoding ([System.Text.Encoding]::UTF8)
}



$UserList = Get-Content $InputFile 
$UserList.Count
$i=0

foreach($user in $UserList){

    Send-Email $user
    write-host "$i $user"
    $i++
}
