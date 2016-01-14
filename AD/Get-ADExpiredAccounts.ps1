################################################################
<#
.SYNOPSIS 
    Gets the List of Accounts Which are Expired

.DESCRIPTION
    This Script Retrives the Name,DisplayName,Enabled,ObjectClass,ManagedBy,LockedOut,LastLogonDate and OU in which the Account is located in.
    Output will be saved in the following path C:\Temp\ and file name starts with Expired_AD_Accounts_

.NOTES
    AUTHOR: SALMO07
    LASTEDIT: August 21, 2015
    Developed on Powershell Version 4
#>
################################################################


#Get the OU of a AD Account from DN

function Get-OU ([String]$DistinguishedName){               
        $o=$null
        foreach($f in $((($DistinguishedName -split “,”, 2)[1]).Split(',')))        
        {
            if($f.SubString(0,3) -ne 'DC='){            
                $o="\"+$f.SubString(3)+$o                
            }              
        }         
        $o="ca.com"+$o;
        return $o   
 }

#Retrieves the expired AD Accounts and Exports into a C:\temp
Search-ADAccount -AccountExpired |`
select Name,SamAccountName,@{L="Description";E={(Get-ADUser $_ -Properties Description).Description}},@{L="AccountStatus";E={if($_.Enabled){"Enabled"}else{"Disabled"}}},ObjectClass,AccountExpirationDate,@{L="Manager";E={(Get-ADUser $_ -Properties Manager).Manager}},LockedOut,LastLogonDate,@{L="Account_location";E={Get-OU $($_.DistinguishedName)}},@{l="MemberOf";e={(get-aduser $_ -Properties memberof).memberof}},@{L="MailboxStatus";e={try{Get-Mailbox $_.SamAccountName -ErrorAction Stop |Out-Null;"found"}catch{"not found"}}} |`
Sort-Object AccountExpirationDate|Export-csv C:\Temp\Expired_AD_Accounts_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation 


#Get-Content C:\Temp\del.txt|%{Get-ADUser $_ -Properties *|select name,SamAccountName,@{L="AccountStatus";E={if($_.Enabled){"Enabled"}else{"Disabled"}}},ObjectClass,AccountExpirationDate,Manager,LastLogonDate,@{L="Account_location";E={Get-OU $($_.DistinguishedName)}},@{l="MemberOfGroups";e={$_|select -ExpandProperty memberof}},@{L="MailboxStatus";e={try{Get-Mailbox $_.SamAccountName -ErrorAction Stop |Out-Null;"found"}catch{"not found"}}}}|Sort-Object AccountExpirationDate|Export-Csv C:\Temp\del_me.csv -NoTypeInformation