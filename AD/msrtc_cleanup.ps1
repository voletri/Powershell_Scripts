




$userlist=get-content C:\Temp\msrtc.txt

$output=@()
foreach($user in $userlist){

$a=Get-ADUser -SearchBase "DC=ca,DC=Com" -filter{samaccountname -eq $user} -properties samaccountname,msRTCSIP-ArchivingEnabled,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-Line,msRTCSIP-LineServer,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-UserEnabled,msRTCSIP-OriginatorSid,msRTCSIP-TargetHomeServer,msRTCSIP-UserExtension,msRTCSIP-UserPolicy|select samaccountname,msRTCSIP-ArchivingEnabled,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-Line,msRTCSIP-LineServer,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-UserEnabled,msRTCSIP-OriginatorSid,msRTCSIP-TargetHomeServer,msRTCSIP-UserExtension,msRTCSIP-UserPolicy

$output=$output+$a
}

$output|export-csv C:\Temp\clear.csv



#$a=Get-ADUser -SearchBase "DC=ca,DC=Com" -filter{samaccountname -eq "malsr04"} -properties samaccountname,msRTCSIP-ArchivingEnabled,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-Line,msRTCSIP-LineServer,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-UserEnabled,msRTCSIP-OriginatorSid,msRTCSIP-TargetHomeServer,msRTCSIP-UserExtension,msRTCSIP-UserPolicy
