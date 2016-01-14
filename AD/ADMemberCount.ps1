Get-ADGroup -Filter * |

foreach {

 $props = [ordered] @{

 GroupName = $_.Name

 MemberCount = Get-ADGroupMember -Identity "$($_.samAccountName)" | Measure-Object | select -ExpandProperty Count

 }

 New-Object -TypeName psobject -Property $props

} | sort MemberCount  | Export-Csv  -Path c:\temp\membercount.csv  -NoTypeInformation