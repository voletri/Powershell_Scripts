$a=Import-Csv C:\Temp\apm_dl_members.csv

$list=$a.name
$SIDDetails_list=@()

foreach($user in $list){

#$user=$list |select -First 1
   $user=$user.Trim()
   $SIDDetails={}|select Name,IP
   $SID=$null
   $SID=Get-ADUser $user -properties * |select sid

   $SIDDetails.Name=$user

   if($SID -eq $null){
        $SIDDetails.IP ="unable_to_retrieve"
   }else{
      $SIDDetails.IP =$SID.sid.Value
    }

   $SIDDetails_list+= $SIDDetails
   $SIDDetails
}

$SIDDetails_list|Export-Csv c:/temp/apm_sid1.csv -NoTypeInformation