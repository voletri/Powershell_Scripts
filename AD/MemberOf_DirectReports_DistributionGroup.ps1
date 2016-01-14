
Function Get-Name_From_DN([String]$DistinguishedName){
        
        return $(($DistinguishedName -split ",")[0].Substring(3))   
}

#Get-ADUser tayve01 -Properties *|select -ExpandProperty managed*
#Get-ADGroup "Team - GIS - CORE - Operations" -Properties *|select Name,ManagedBy,@{l="ManagedBy1";e={Get-Name_From_DN $($_.ManagedBy)}}
#Get-ADGroup "Team - GIS - CORE - Operations" -Properties ManagedBy|select @{l="ManagedBy";e={Get-Name_From_DN $($_.ManagedBy)}}|select -ExpandProperty ManagedBy


function Get-ADDirectReports ([String]$Account) {
	PROCESS
	{
					Get-Aduser -identity $Account -Properties directreports |
					ForEach-Object -Process {
						$_.directreports | ForEach-Object -Process {
							# Output the current object with the properties Name, SamAccountName, Mail
							Get-ADUser -Identity $PSItem -Properties SamAccountName,Title,Department,co,Manager,Office,City,MemberOf,band|where{$_.band}|select SamAccountName,Title,Department,co,@{l="Manager";e={Get-Name_From_DN $($_.Manager)}},Office,City,MemberOf,DLMemberShip,DLManager
							# Gather DirectReports under the current object and so on...
							Get-ADDirectReports $PSItem
						}
					}
		}
}

$OutputFile ="C:\Temp\All_Users_DL_Membership_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"
$Userlist=Get-ADUser -SearchBase "DC=ca,DC=Com" -Filter {band -like "*"} -Properties SamAccountName,Title,Department,co,Manager,Office,City,MemberOf,band|select SamAccountName,Title,Department,co,@{l="Manager";e={($_.Manager -split ",")[0].Substring(3)}},Office,City,MemberOf,DLMemberShip

$Userlist.Count
$Userlist|Export-Csv C:\Temp\ALL_AD_User_Data_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation

Get-ADGroup -Filter {GroupCategory -eq "Distribution"} -Properties CN,DisplayName,ManagedBy -ResultSetSize $null -SearchBase "DC=ca,DC=Com"|select Name,@{l="ManagedBy";e={Get-Name_From_DN $_.ManagedBy}}|Export-Csv C:\Temp\ALL_DL_Group_Data_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv -NoTypeInformation

<#
#$OutputFile ="C:\Temp\$($EndUser)_Users_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"
#$EndUser="comma05"
#$Userlist=Get-ADDirectReports $EndUser
#>

<#
$User=Get-ADUser "salmo07" -Properties SamAccountName,Title,Department,co,Manager,Office,City,MemberOf,band|where{$_.band}|select SamAccountName,Title,Department,co,@{l="Manager";e={($_.Manager -split ",")[0].Substring(3)}},Office,City,MemberOf,DLMemberShip,DLManager
#>
$Userlist|%{

    $User=$_;

    if($($User.MemberOf) -ne $null){
        
        $($User.MemberOf)|%{        
            
            $dl=$Null
            $dl=Get-ADGroup $_|where{$_.GroupCategory -eq "Distribution"}|select -ExpandProperty Name
    
            if($dl -ne $Null){
                
                $User.DLManager=Get-ADGroup $_ -Properties ManagedBy|select @{l="ManagedBy";e={Get-Name_From_DN $($_.ManagedBy)}}|select -ExpandProperty ManagedBy

                #$User.DLManager=Get-ADGroup $_  -Properties ManagedBy|select -ExpandProperty @{l="ManagedBy";e={Get-Name_From_DN $($_.ManagedBy)}}

                $User.DLMemberShip=$dl
                $User|select SamAccountName,Title,Department,co,Manager,Office,City,DLMemberShip,DLManager
            }
        }
      }else{
        $User|select SamAccountName,Title,Department,co,Manager,Office,City,DLMemberShip,DLManager
    }

}|export-csv $OutputFile -NoTypeInformation