$c=get-acl $folder| select-object path,owner,@{l="Groups";e={($_. AccessToString)}},group

$c.Groups

(Get-ADDomain).NetBIOSName

########################
$Output = @()
$DirList = GCI \\server\share -directory | %{$_.FullName; GCI $_ -Directory|select -expandproperty FullName}
ForEach($Dir in $DirList){
    $ACLs=@()
    (get-acl $Dir).accesstostring.split("`n")|?{$_ -match "^(.+?admin(istrators|141))\s+?(\w+?)\s+?(.+)$"}|%{
        $ACLs+=[PSCUSTOMOBJECT]@{Group=$Matches[1];Type=$Matches[2];Access=$Matches[3]}
    }
    ForEach($ACL in $ACLs){
        if($Members){Remove-Variable Members}
        $Members = Get-ADGroupMember $ACL.Group -ErrorAction SilentlyContinue|%{[string]$_.SamAccountName}
        $Output += "$Dir $($ACL.Group) $($ACL.Access) $($Members -join ",")"
    }
}
####################