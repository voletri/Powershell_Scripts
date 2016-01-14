<#
Name:Get-AD-OnPremUserReport
Purpose:To retrieve all the OnPrem Users Mailboxes for EXchange Online Migrations from Active Directory
Description:To Get all the OnPrem Users Mailboxes excluding Generic Mailboxes, excluding the User Mailboxes with below Titles

Chief* 
General Manager*
Vice Chairman*
EVP*
Distinguished Engineer*
SVP*
VP*
Administrative Assistant*
Sr Administrative Assistant*
Executive Assistant*
Administrative Coordinator*
*Communication*
*PreSales*

and Exclude the users in the below DLP Groups
"DLPInScopeFinance","DLPInScopeSaaS","DLPInScopeHR","DLPInScopeSupport","DLPInScopeProfServ","DLPInScopeEMT","DLPOutOfScopeSupport","DLPOutOfScopeSaaS","DLPOutOfScopeProfServ","DLPOutOfScopeHR","DLPOutOfScopeFinance"

Created Date: 26th August 2015
Author: salmo07
#>

$UserList=Get-ADUser -SearchBase "DC=ca,DC=Com" `
-Filter {(mail -notlike "*@arcserve.com") -and (extensionAttribute2 -eq "webmail10.ca.com") -and (extensionAttribute4 -eq "EOPNamedUser") -and (Title -notlike "Chief*") -and (Title -notlike "General Manager*") -and (Title -notlike "Vice Chairman*") -and (Title -notlike "EVP*") -and (Title -notlike "Distinguished Engineer*") -and (Title -notlike "SVP*") -and (Title -notlike "VP*") -and (Title -notlike "Administrative Assistant*") -and (Title -notlike "Sr Administrative Assistant*") -and (Title -notlike "Executive Assistant*") -and (Title -notlike "Administrative Coordinator*") -and (Title -notlike "*Communication*") -and (Title -notlike "*PreSales*")} `
-properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4

$UserList|Export-Csv c:/temp/Onprem_UserMailboxes_fromAD.csv -NoTypeInformation

Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(Title -like "Chief*") -or (Title -like "General Manager*") -or (Title -like "Vice Chairman*") -or (Title -like "EVP*") -or (Title -like "Distinguished Engineer*") -or (Title -like "SVP*") -or (Title -like "VP*") -or (Title -like "Administrative Assistant*") -or (Title -like "Sr Administrative Assistant*") -or (Title -like "Executive Assistant*") -or (Title -like "Administrative Coordinator*") -or (Title -like "*Communication*") -or (Title -like "*PreSales*")} -properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4|Export-Csv c:/temp/Tittle_Excluded_Users.csv -NoTypeInformation

$groupList="DLPInScopeFinance","DLPInScopeSaaS","DLPInScopeHR","DLPInScopeSupport","DLPInScopeProfServ","DLPInScopeEMT","DLPOutOfScopeSupport","DLPOutOfScopeSaaS","DLPOutOfScopeProfServ","DLPOutOfScopeHR","DLPOutOfScopeFinance"

$memberlist=$groupList|%{Get-ADGroupMember -Identity $_|select name}

$memberlist|select name|export-csv C:\Temp\dlp_members.csv -NoTypeInformation

$members=$($memberlist.name)
$NonDLP=$UserList|where{$members -notcontains $_.samaccountname}

$NonDLP|Export-Csv c:/temp/All_Onprem_UserMailboxes_nonDLP_fromAD.csv -NoTypeInformation