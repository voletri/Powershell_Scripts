$a = Get-ADUser -Identity $env:username  -Properties * 

$a.nTSecurityDescriptor |
Select-Object -ExpandProperty Access |
Select-Object *