

Function Send-AdminEmail ($Body){

#$FromEmail="itpam@ca.com"
$ToEmail="salmo07@ca.com"
$FromEmail="salmo07@ca.com"

$MailServer="mail.ca.com"
$subject="Unable to ADD"

$Body=ConvertTo-Html $Body

Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $MailServer -Subject $subject -Body $Body -bodyasHTML -priority High 
}



$AllEmployeeUserList=Get-ADUser -Filter 'employeetype -eq "F"'|select -ExpandProperty SamAccountName

$GroupName="TestDL"
$GroupUserList=Get-ADGroupMember -Identity $GroupName -Recursive | select -ExpandProperty SamAccountName

$AllEmployeeUserList=$AllEmployeeUserList|select -First 5

$DiffResults=Compare-Object -ReferenceObject $AllEmployeeUserList -DifferenceObject $GroupUserList
$NewUsersToAdd=$DiffResults|where{$_.SideIndicator -eq '<='}| select -ExpandProperty InputObject

$NewUsersToAdd|%{Add-ADGroupMember -Identity $GroupName -Members $_}


#$ExistingUsersToRemove=$DiffResults|where{$_.SideIndicator -eq '=>'}| select -ExpandProperty InputObject
#$ExistingUsersToRemove|%{Remove-ADGroupMember -Identity $GroupName -Members $_}


$Post_GroupUserList=Get-ADGroupMember -Identity $GroupName -Recursive | select -ExpandProperty SamAccountName

$Post_Results=Compare-Object -ReferenceObject $AllEmployeeUserList -DifferenceObject $Post_GroupUserList

if($Post_Results.count -ne 0){
    
    $Post_Results|Export-Csv C:\Temp\Unable_to_add.csv -NoTypeInformation

    Send-AdminEmail $Post_Results

}




$temp1=$AllEmployeeList|select -last 15
$temp2=$AllEmployeeList|select -last 14

$newUsers=Compare-Object -ReferenceObject $temp1 -DifferenceObject $temp2| select -ExpandProperty InputObject
$newUsers.count

$GroupUserList.Count



Get-ADGroup -Filter{name -like "*Test*"} -Properties Name -SearchBase "DC=ca,DC=Com" | Select-Object Name
Get-ADGroup "TestDL"


Get-ADGroupMember "TestDL"


$a=Compare-Object -ReferenceObject $AllEmployeeUserList -DifferenceObject $GroupUserList
$a.SideIndicator[0].GetType()

$a.SideIndicator[0] -eq "=>"