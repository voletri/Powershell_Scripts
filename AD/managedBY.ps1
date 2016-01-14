Get-ADUser sg-salmo07 -Properties * |select msExchCoManagedObjectsBL

#ObjectCategory : CN=Person,CN=Schema,CN=Configuration,DC=ca,DC=com
Get-ADUser tayve01 -Properties * |fl managedObjects
Get-ADUser sg-sirki01 -Properties * |fl managedObjects
Get-ADUser petsr01 -Properties * |fl managedObjects
Get-ADUser tumka01 -Properties * |fl managedObjects
Get-ADUser sg-salmo07 -Properties * |fl managedObjects


Get-ADGroup dl-csm1001
Get-ADGroup "Team - GIS - CORE - Operations"