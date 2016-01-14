
#Get the Name from the DistinguishedName
Function Get-Name_From_DN([String]$DistinguishedName){
        
        return $(($DistinguishedName -split ",")[0].Substring(3))   
}

#Get the DirectReports of Each User

function Get-ADDirectReports ([String]$Account) {
	PROCESS
	{
					Get-Aduser -identity $Account -Properties directreports |
					ForEach-Object -Process {
						$_.directreports | ForEach-Object -Process {
							# Output the current object with the properties Name, SamAccountName, Mail
							Get-ADUser -Identity $PSItem -Properties SamAccountName,Title,Department,co,Manager,Office,City,MemberOf,band,Displayname,office,co,region,l|where{$_.band}|select SamAccountName,Displayname,Title,Department,co,@{l="Manager";e={Get-Name_From_DN $($_.Manager)}},office,region,l
							# Gather DirectReports under the current object and so on...
							Get-ADDirectReports $PSItem
						}
					}
		}
}

$evp="becri02"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="berot01"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="bismi02"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="DILGU02"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="ELSAD01"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="flala01"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="lamja01"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="propa05"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation

$evp="sayay01"
Get-ADDirectReports $evp|Export-Csv C:\Temp\evpReport_$evp.csv -NoTypeInformation