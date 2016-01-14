#Get-WmiObject win32_share | Select-Object name, path, description, type | Format-Table -autosize

#Server Admin - UKSLWS1000 

$outfile="C:\Temp\CyberSecurity_AD_final.csv"

$UserList=Get-Content C:\Temp\security_users.txt

$UserServerList=$UserList|Get-ADUser -Properties MemberOf|where{$_.MemberOf -like "*Admin Global Group - ca.com*"}`
|select SamAccountName,Enabled,@{l="Servers";e={($_.MemberOf|%{if($_ -match 'Admin Global Group - ca.com'){($_ -split " ")[0].Substring(3)}})}} 

$UserServerList|%{
    
    $user=$_
    
    foreach($server in $($user.Servers)){   
        {}|select @{l="PMF_Key";e={$($user.SamAccountName)}},@{l="Server";e={$server}},@{l="SecurityGroupName";e={"$($server) Admin Global Group - ca.com"}}
    }

}|Export-Csv $outfile -NoTypeInformation


$grouplist=Get-ADGroup -SearchBase "DC=ca,DC=Com" -Filter{name -like "*"} -Properties MemberOf,members|where{$_.MemberOf -like "*Admin Global Group - ca.com*"}`
|select @{l="SecurityGroupName";e={$_.SamAccountName}},@{l="Servers";e={($_.MemberOf|%{if($_ -match 'Admin Global Group - ca.com'){($_ -split " ")[0].Substring(3)}})}}, `
@{L="Users";e={Get-ADGroupMember $_.SamAccountName -Recursive|select -ExpandProperty name }}

#$grouplist|export-csv C:\Temp\security_groups2.csv -NoTypeInformation

$grouplist|%{
 
 $group = $_
 
 foreach($user in $UserList){
 
    if($($group.Users) -contains $user){
        
        foreach($s in $($group.Servers)){

            {}|select @{l="PMF_Key";e={$user}},@{l="Server";e={$s}},@{l="SecurityGroupName";e={$group.SecurityGroupName}}   
        } 
    }
 
 }

}|Export-Csv $outfile -NoTypeInformation -Append
