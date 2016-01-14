﻿# Search for all users in the domain, using PowerShell v1 syntax
$Searcher = New-Object DirectoryServices.DirectorySearcher
$Searcher.Filter = '(objectcategory=user)'
$Searcher.FindAll().Count

# Search for all users in the domain using [adsisearcher] type accelerator, PowerShell v2 syntax
([adsisearcher]'(objectcategory=user)').FindAll().Count

# Search for administrator and display its properties
([adsisearcher]'(samaccountname=administrator)').FindOne()
([adsisearcher]'(samaccountname=administrator)').FindOne().properties

# Display pwdlastset parameter of Administrator
$ADSIAdmin = ([adsisearcher]'(samaccountname=administrator)').FindOne()
$ADSIAdmin.properties.pwdlastset

# [adsisearcher] always returns arrays, to retrieve the correct data index into the array
$ADSIAdmin.properties.pwdlastset.GetType()
$ADSIAdmin.properties.pwdlastset[0].GetType()

# Use the DateTime .NET Class to convert the FileTime to a DateTime object
[DateTime]::FromFileTime($ADSIAdmin.properties.pwdlastset[0])

# Search for a computer account, samaccountname includes dollar sign
([adsisearcher]'(samaccountname=jbdc01)').FindOne()
([adsisearcher]'(samaccountname=jbdc01$)').FindOne()

# Search for all users that do not have homedirectory attribute set
([adsisearcher]'(!homedirectory=*)').FindAll()
([adsisearcher]'(&(objectcategory=user)(!homedirectory=*))').FindAll()
([adsisearcher]'(&(objectcategory=user)(!homedirectory=*))').FindAll().Count

# Update the homedirectory attribute for every user that currently lacks one
([adsisearcher]'(&(objectcategory=user)(!homedirectory=*))').FindAll() | 
ForEach-Object {
    $CurrentUser = [adsi]$_.Path
    $CurrentUser.homedirectory = "\\JBDC01\Home\$($CurrentUser.samaccountname)"
    $CurrentUSer.SetInfo()
}

# No users should be returned when we re-run this query
([adsisearcher]'(&(objectcategory=user)(!homedirectory=*))').FindAll().Count

# To view the Homedirectory of a random user this example can be executed
([adsisearcher]'(&(objectcategory=user)(homedirectory=*))').FindAll() | 
Get-Random | ForEach-Object {
    "Name: $($_.properties.name)"
    "Home: $($_.properties.homedirectory)"
}

# Displays the homedirectory attribute of the current administrator
[adsi]'LDAP://jbdc01.jb.com/CN=Administrator,CN=Users,DC=jb,DC=com'
([adsi]'LDAP://jbdc01.jb.com/CN=Administrator,CN=Users,DC=jb,DC=com').homedirectory


# Utilize ADSI to read information from the domain
[adsi]''
$Domain = [adsi]'LDAP://DC=jb,DC=com'
$Domain | Select-Object -Property *
$Domain.Properties
$Domain.Properties.minPwdLength
$Domain.Properties.whenCreated
$Domain.Properties.fsMORoleOwner

# Search for all computer objects in the Domain Controllers OU
$Searcher = New-Object DirectoryServices.DirectorySearcher
$Searcher.Filter = '(objectcategory=computer)'
$Searcher.SearchRoot = 'LDAP://OU=Domain Controllers,DC=jb,DC=com'
$Searcher.FindAll()

# Display the homedirectory attribute of the administrator user on all available domain controllers. This can be used to have a detailed look at attributes and to verify they have been correctly replicated
(New-Object adsisearcher([adsi]'LDAP://OU=Domain Controllers,DC=jb,DC=com','(objectcategory=computer)')).FindAll() |
ForEach-Object {
    $HashProp = @{ Server = $_.Properties.dnshostname[0]
                   HomeDir = ([adsi]"LDAP://$($_.properties.dnshostname)/CN=Administrator,CN=Users,DC=jb,DC=com").homedirectory[0]
                   }
    New-Object -TypeName PSCustomObject -Property $HashProp
}

# Create an OU
$Domain = [adsi]'LDAP://DC=jb,DC=com'
$CreateOU = $Domain.Create('OrganizationalUnit','OU=NewOUinRootofDomain')
$CreateOU.SetInfo()

# Create Group in OU
$CurrentOU = [adsi]"LDAP://OU=NewOUinRootofDomain,DC=jb,DC=com"
$CreateGroup = $CurrentOU.Children.Add('CN=HappyUsers', 'Group')
$CreateGroup.CommitChanges()

# Update the samaccount name of the group
$CreateGroup.samaccountname = 'happyusers'
$CreateGroup.CommitChanges()

# Create user
$CreateUser = $CurrentOU.Children.Add('CN=JaapBrasser', 'User')
$CreateUser.CommitChanges()

# Delete user
$NewUser = [adsi]"LDAP://CN=JaapBrasser,OU=NewOUinRootofDomain,DC=jb,DC=com"
$NewUser.DeleteTree()

# Create user
$CreateUser = $CurrentOU.Children.Add('CN=JaapBrasser', 'User')
$CreateUser.CommitChanges()

# Update user attributes
$NewUser = [adsi]"LDAP://CN=JaapBrasser,OU=NewOUinRootofDomain,DC=jb,DC=com"
$NewUser.Put('sAMAccountName','jaapbrasser')
$NewUser.Put('givenname','Jaap')
$NewUser.Put('sn','Brasser')
$NewUser.Put('displayname','Jaap Brasser')
$NewUser.Put('description','Account created using ADSI')
$NewUser.Put('userprincipalname','JaapBrasser@jb.com')
$NewUser.SetInfo()

# Set password and enable account
$NewUser.SetPassword('Secret01')
$NewUser.psbase.InvokeSet('AccountDisabled',$false)
$NewUser.SetInfo()

# Add user to group
$NewGroup = [adsi]"LDAP://CN=HappyUsers,OU=NewOUinRootofDomain,DC=jb,DC=com"
$NewGroup.Add($NewUser.Path)

# Shortened version of adding a user to a group using ADSI
([adsi]'LDAP://CN=TestGroup,CN=Users,DC=jb,DC=com').Add($NewUser.Path)

#Ambiguous Name Resolution this can be used to query LDAP
([adsisearcher]'(anr=jaap*)').FindAll()
([adsisearcher]'(anr=jaap*)').FindAll()[1].properties

# Display the attributes of the jaapbrasser AD account
([adsisearcher]'(samaccountname=jaapbrasser)').FindAll()
([adsisearcher]'(samaccountname=jaapbrasser)').FindOne().Properties.memberof
([adsisearcher]'(samaccountname=jaapbrasser)').FindOne().Properties.memberof[0]
([adsisearcher]'(samaccountname=jaapbrasser)').FindOne().Properties.memberof[1]

# Delete the OU and all of its contents
$CurrentOU.DeleteTree()