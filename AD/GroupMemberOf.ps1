$list=get-content "C:\temp\groups.txt"

$list|%{$group=$_.trim();Get-ADGroup $group -Properties * |select name,@{l="MemberOfS";e={($_.MemberOf|%{($_ -split ",")[0].Substring(3)}) -join ','}}}|Export-Csv C:\Temp\role_me1.csv -NoTypeInformation