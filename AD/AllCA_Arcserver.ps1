

#To Get All CA Employee
Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter * -properties samaccountname,DisplayName,office,co,region,title,l |select  samaccountname,DisplayName,Title,office,co,region,l |Export-Csv c:/temp/All_CA.csv -NoTypeInformation


#To Get the Arcserve Users
Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {mail -like "*@arcserve.com"} -Properties SamAccountName,mail|select SamAccountName,mail|Export-Csv c:\temp\arcserve.csv -NoTypeInformation

Get-ADUser "ganar03" -Properties * |fl ex*

#webmail10 has the all onpremmailboxes
#EOPNamedUser has all the user mailboxes not generic mailboxes

Get-ADUser -SearchBase "DC=ca,DC=Com" `
-Filter {(mail -notlike "*@arcserve.com") -and (extensionAttribute2 -eq "webmail10.ca.com") -and (extensionAttribute4 -eq "EOPNamedUser") -and (Title -notlike "Chief*") -and (Title -notlike "General Manager*") -and (Title -notlike "Vice Chairman*") -and (Title -notlike "EVP*") -and (Title -notlike "Distinguished Engineer*") -and (Title -notlike "SVP*") -and (Title -notlike "VP*") -and (Title -notlike "Administrative Assistant*") -and (Title -notlike "Sr Administrative Assistant*") -and (Title -notlike "Executive Assistant*") -and (Title -notlike "Administrative Coordinator*") -and (Title -notlike "*Communication*") -and (Title -notlike "*PreSales*")} `
-properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4 `
|Export-Csv c:/temp/CA_Onprem_UserMailboxes_fromAD.csv -NoTypeInformation

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(Title -notlike "Chief*") -and (Title -notlike "General Manager*") -and (Title -notlike "Vice Chairman*") -and (Title -notlike "EVP*") -and (Title -notlike "Distinguished Engineer*") -and (Title -notlike "SVP*") -and (Title -notlike "VP*") -and (Title -notlike "Administrative Assistant*") -and (Title -notlike "Sr Administrative Assistant*") -and (Title -notlike "Executive Assistant*") -and (Title -notlike "Administrative Coordinator*") -and (Title -notlike "*Communication*") -and (Title -notlike "*PreSales*")} -properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4|Export-Csv c:/temp/CA_VIP.csv -NoTypeInformation

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(Title -like "Chief*") -or (Title -like "General Manager*") -or (Title -like "Vice Chairman*") -or (Title -like "EVP*") -or (Title -like "Distinguished Engineer*") -or (Title -like "SVP*") -or (Title -like "VP*") -or (Title -like "Administrative Assistant*") -or (Title -like "Sr Administrative Assistant*") -or (Title -like "Executive Assistant*") -or (Title -like "Administrative Coordinator*") -or (Title -like "*Communication*") -or (Title -like "*PreSales*")} -properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4|Export-Csv c:/temp/CA_VIP.csv -NoTypeInformation
<#
title
Chief* 
General Manager*
Vice Chairman*
EVP*
Distinguished Engineer*
SVP*
VP*
Administrative Assistant
Sr Administrative Assistant
Executive Assistant
Administrative Coordinator
*Communication*
*PreSales*

#>