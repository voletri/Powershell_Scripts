

$RootfolderPath="C:\Users\salmo07\Documents\Scripts\PowershellScripts"
#$RootfolderPath="C:\"

$SearchString="-LDAPFilter"

$fileList=Get-ChildItem -Recurse -Force $RootfolderPath | Where-Object { $_.PSIsContainer -eq $true } | Select-Object Name,FullName

$output=@()
foreach($file in $fileList){
    $o=Select-String -Path $($($file.FullName)+"\*.ps1") -pattern $SearchString |select Filename,Path,Line,LineNumber,Pattern
    $output=$output+$o
}
$output|Export-Csv C:\Temp\FileSearch.csv -NoTypeInformation