<#

.DESCRIPTION
    This Script gives a report of all the objects in a OU in AD

.Required 
    Active Directory Module

.NOTES
    AUTHOR: SALMO07
#>

Import-Module ActiveDirectory

#To Get all the Objects in a OU
$OU="OU=Room Mailbox,OU=Role-Based,OU=North America,DC=ca,DC=com"

$OutputFile="C:\Temp\room_OU_Objects.csv"

Get-ADObject -Filter * -SearchBase $OU -Properties name,Displayname,mail,ObjectClass|select name,Displayname,mail,ObjectClass|export-csv $OutputFile -NoTypeInformation 