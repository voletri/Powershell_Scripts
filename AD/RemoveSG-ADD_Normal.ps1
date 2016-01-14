
$Group="XU-domain-admins"

Get-ADGroup $Group |Get-ADGroupMember|foreach{

    $member=$null
    $member=$_.SamAccountName

        if(($member).StartsWith("SG-") -or ($member).StartsWith("sg-")){
        
            Write-Host "Adding $($member.Substring(3))"
            Add-ADGroupMember -Identity $Group -Members $($member.Substring(3))
        }
        Write-Host "Removing $($member)"
        Remove-ADGroupMember -Identity $Group -Members $($member) -Confirm:$false
}


    #    Remove-ADGroupMember -Identity $Group -Members $($member) -Confirm:$false