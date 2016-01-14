
$User="kunkr03"
$group="SSL Monitor"

$userCheck=$Null
$userCheck=Get-ADUser $User

$groupCheck=$Null
$groupCheck=Get-ADGroup $group


if($userCheck -ne $Null){

    if($groupCheck -ne $Null){

        $PreGroupCheck=Get-ADGroupMember $group|select -ExpandProperty name

        if($PreGroupCheck -contains $User){

            $status="user already exists"

        }else{

            Add-ADGroupMember -Identity $group -Members $User

            $PostGroupCheck=Get-ADGroupMember $group|select -ExpandProperty name

            if($PostGroupCheck -contains $User){

                $status="success"

            }else{

                $status= "unable to add"
            }
        }

    }else{
        $status= "group not found"
    }
}else{

$status= "usernot found"

}


#$c=Get-ADGroupMember $group|select name

#$groupcheck=Get-ADGroupMember $group|select -ExpandProperty name

#Get-ADGroup $group -Properties *|fl Members