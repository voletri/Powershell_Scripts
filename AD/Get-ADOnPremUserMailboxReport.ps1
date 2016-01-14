<#######################################################################################

.Name:Get-ADOnPremUserMailboxReport.ps1

.Purpose:To Get a Report of all the OnPrem Users Mailboxes Eligible for Exchange Online 0365 Migrations

.Description:Script retrieves
    (i) All the OnPrem Users Mailboxes 
   (ii) Excluding Generic Mailboxes
  (iii) Excluding Arcserve Mailbox Users
   (iV) Excluding the User Mailboxes with below Titles
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

   (V) Exclude the users in the below DLP Groups
        a.	DLPInScopeFinance
        b.	DLPInScopeSaaS
        c.	DLPInScopeHR
        d.	DLPInScopeSupport
        e.	DLPInScopeProfServ
        f.	DLPInScopeEMT
        g.	DLPOutOfScopeSupport
        h.	DLPOutOfScopeSaaS
        i.	DLPOutOfScopeProfServ

.Required: Active Directory Module, Powershell Version 4
.Note: Output Files will be saved in Temp
.Created Date: 26th August 2015
.Author: salmo07

########################################################################################>

#Retrieves the OnPrem User Mailboxes, Excluding Generic Mailboxes, Excluding Arcserve Mailbox Users, Excluding the User Mailboxes with the above Titles

$UserList=Get-ADUser -SearchBase "DC=ca,DC=Com" `
-Filter {(mail -notlike "*@arcserve.com") -and (extensionAttribute2 -eq "webmail10.ca.com") -and (extensionAttribute4 -eq "EOPNamedUser") -and (Title -notlike "Chief*") -and (Title -notlike "General Manager*") -and (Title -notlike "Vice Chairman*") -and (Title -notlike "EVP*") -and (Title -notlike "Distinguished Engineer*") -and (Title -notlike "SVP*") -and (Title -notlike "VP*") -and (Title -notlike "Administrative Assistant*") -and (Title -notlike "Sr Administrative Assistant*") -and (Title -notlike "Executive Assistant*") -and (Title -notlike "Administrative Coordinator*") -and (Title -notlike "*Communication*") -and (Title -notlike "*PreSales*")} `
-properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4

#Exporting the Output to Onprem_UserMailboxes_fromAD.csv
$UserList|Export-Csv c:/temp/Onprem_UserMailboxes.csv -NoTypeInformation

#Exports the Excluded Title Users list
Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {(Title -like "Chief*") -or (Title -like "General Manager*") -or (Title -like "Vice Chairman*") -or (Title -like "EVP*") -or (Title -like "Distinguished Engineer*") -or (Title -like "SVP*") -or (Title -like "VP*") -or (Title -like "Administrative Assistant*") -or (Title -like "Sr Administrative Assistant*") -or (Title -like "Executive Assistant*") -or (Title -like "Administrative Coordinator*") -or (Title -like "*Communication*") -or (Title -like "*PreSales*")} -properties samaccountname,DisplayName,office,co,region,title,l,extensionAttribute2,extensionAttribute4|select samaccountname,DisplayName,title,office,co,region,l,extensionAttribute2,extensionAttribute4|Export-Csv c:/temp/Excluded_Title_Users.csv -NoTypeInformation

#Input Group Names
$groupList="DLPInScopeFinance","DLPInScopeSaaS","DLPInScopeHR","DLPInScopeSupport","DLPInScopeProfServ","DLPInScopeEMT","DLPOutOfScopeSupport","DLPOutOfScopeSaaS","DLPOutOfScopeProfServ","DLPOutOfScopeHR","DLPOutOfScopeFinance"

#Retrieves the DLP Group MemberShips
$memberlist=$groupList|%{Get-ADGroupMember -Identity $_|select name}

#Exporting the DLP Members to dlp_members.csv
$memberlist|select name|export-csv C:\Temp\DLP_GroupMemberList.csv -NoTypeInformation

#Excludes the Userslist who are part of DLP Groups
$members=$($memberlist.name)
$NonDLP=$UserList|where{$members -notcontains $_.samaccountname}

#Exporting the Final UserList Excluding the DLP Users
$NonDLP|Export-Csv c:/temp/AllOnprem_UserMailboxes_NonDLP_fromAD.csv -NoTypeInformation