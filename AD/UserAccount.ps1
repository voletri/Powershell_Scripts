$Reports=@()
$UserList = get-content C:\Users\Salmo07\Desktop\UserList.txt

foreach ($User in $UserList)
{

$user=$user.Trim()

$UserName = Get-ADUser -Filter {sAMAccountName -eq $User}

If ($UserName -eq $Null) {
$report=New-Object -TypeName PSObject -Property @{SamAccountName = $User
DisplayName = "Account doesn't exist"
}                                            

}
Else 
{
$report = Get-Aduser -Identity "$($User)" -Properties SamAccountName,DisplayName,Enabled | Select SamAccountName,DisplayName,Enabled
}

$reports=$reports+$report

}
$reports | export-csv C:\Users\Salmo07\Desktop\Users.csv -noType
