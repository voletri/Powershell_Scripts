
$Serverlist=Get-Content C:\Temp\groups.txt
$member="aimadmin";

$HostDetails_list=@()

foreach($Server in $Serverlist){

    $groupCheck=$null
    $group="$($Server) Admin Global Group - ca.com"
    $groupCheck=Get-ADGroup $group
    
    $memberStatus={}|select Server,Group,Status
    $memberStatus.Server=$Server
    $memberStatus.Group=$Group

if($groupCheck -ne $null){

    $memberList=Get-ADGroupMember $group -Recursive|select name

    if($memberList.name -contains $member){

        $memberStatus.Status="Already a Member"

    }else{

        Add-ADGroupMember -Identity $group -Members $member
        $membercheck=Get-ADGroupMember $group -Recursive|select name

        if($membercheck.name -contains $member){
            $memberStatus.Status="Added"
        }else{
            $memberStatus.Status="Unable to Add"
        }
    }

}else{
     $memberStatus.Status="Group not found"
}

$HostDetails_list=$HostDetails_list+$memberStatus

$memberStatus
}

$HostDetails_list|Export-Csv C:\Temp\status_prod.csv -NoTypeInformation