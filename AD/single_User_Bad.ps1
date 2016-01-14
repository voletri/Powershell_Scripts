
$user="edida01"

$DomainControllers = Get-ADDomainController -Filter *
$Computers =$DomainControllers.HostName |select 

foreach($a in $Computers){

    Get-ADUser $user -Server $a -Properties badPwdCount,LockedOut,LastBadPasswordAttempt |select @{L="DC";E={$a}},badPwdCount,LastBadPasswordAttempt,LockedOut
}
#Get-ADUser salmo07 -Properties *|fl *bad*