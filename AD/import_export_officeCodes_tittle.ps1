
$details=import-csv C:\temp\mail.csv
#$pmf=$details|select -last 1
$details.count
$userObj = {}|select 'Display Name','PMF Key',RecipientType,'Recipient OU',Database,TotalItemSize,ItemCount,'Office Code',Title

$userObj |Export-Csv C:\temp\mail7.csv -NoTypeInformation

foreach($pmf in $details){


$user=Get-ADUser $pmf.'PMF Key' -Properties *|select Office,title,alias

if($user -ne $null){
    $pmf | Add-Member NoteProperty -Name "Office Code" -Value $user.Office -Force
    $pmf | Add-Member NoteProperty -Name "Title" -Value $user.title -Force
    $pmf|Export-Csv C:\temp\mail7.csv -NoTypeInformation -Append
}else{
    $pmf | Add-Member NoteProperty -Name "Office Code" -Value "NotFound/Unable to Retrieve" -Force
    $pmf | Add-Member NoteProperty -Name "Title" -Value "NotFound/Unable to Retrieve" -Force
    $pmf|Export-Csv C:\temp\mail7.csv -NoTypeInformation -Append
}

$user=$null
}