<#Protected Groups and Members

You might have faced permission denied (The user has insufficient access rights) problem when modifying a user object, reset password and using Send as permissions in Exchange servers. When permissions are delegated to non-admin users, these permissions rely on the user object that inherits the permissions from the parent container. Members of protected groups do not inherit permissions from the parent container, therefore, these permissions are not applied to members of protected groups. So even though permissions are assigned higher up in the tree, they may not be implemented on users or objects that are members of built-in groups/protected groups. 

The Active Directory attribute adminCount indicates whether group is a Protected Group or user is a Protected group Member. 

The following Active Directory Powershell cmdlet command detect which users and groups are affected by Protected Group status. 
#>

#List AD Protected Users: 
Import-Module ActiveDirectory
Get-ADUser -LDAPFilter "(admincount=1)" | Select Name,DistinguishedName
#List AD Protected Groups: 
Import-Module ActiveDirectory
Get-ADGroup -LDAPFilter "(admincount=1)" | Select Name,DistinguishedName
Export AD Protected Users to CSV: 
Import-Module ActiveDirectory
Get-ADUser -LDAPFilter "(admincount=1)" |
   Select Name,DistinguishedName |
   Export-CSV "C:\\ProtectedADUsers.csv" -NoTypeInformation -Encoding UTF8

<#
Default protected administrative groups in Active Directory: 
Enterprise Admins
Schema Admins
Domain Admins
Administrators
Account Operators
Server Operators
Print Operators
Backup Operators
Cert Publishers
Domain Controllers
Read-Only Domain Controllers
Replicator
#>