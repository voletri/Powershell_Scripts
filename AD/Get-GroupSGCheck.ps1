 
 
 $group="Intel L2"
 $memberList=Get-ADGroupMember "$($group)" -Recursive|select samaccountname

$memberList=$memberList.samaccountname

 $list=get-content "C:\temp\intel.txt"

$output=@()
foreach($user in  $list){
    
   $o={}|select user,sg_user,SG_Account_GroupCheck
   $o.user=$user  
                                                       
   if($user -notlike "SG-*"){
        $user="SG-$user"
   }

   $o.sg_user=$user  

   $a="false"

   if( $memberList -contains $user){
    
    $a="true"
   
   }
    
    $o.SG_Account_GroupCheck= $a

    $output+=$o
}

$output|export-csv c:\temp\intel.csv -NoTypeInformation