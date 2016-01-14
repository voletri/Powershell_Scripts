
$details=import-csv C:\temp\mail.csv
#$pmf=$details|select -last 1

foreach($pmf in $details){

$user=$null
$user=Get-ADUser $pmf.'PMF Key' -Properties *|select Office,title

if($user -ne $null){
#$userObj = New-Object PSObject

$pmf | Add-Member NoteProperty -Name "Office Code" -Value $user.Office -Force
$pmf | Add-Member NoteProperty -Name "Title" -Value $user.title -Force
$pmf|Export-Csv C:\temp\mail1.csv -NoTypeInformation -Append
}else{
$pmf | Add-Member NoteProperty -Name "Office Code" -Value "NotFound/Unable to Retrieve" -Force
$pmf | Add-Member NoteProperty -Name "Title" -Value "NotFound/Unable to Retrieve" -Force
$pmf|Export-Csv C:\temp\mail1.csv -NoTypeInformation -Append

}

}