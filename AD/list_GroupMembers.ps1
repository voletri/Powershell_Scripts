$GroupNamesList = get-content C:\Users\salmo07\Desktop\output\GroupNamesList.txt

foreach ($GroupName in $GroupNamesList)
{
Get-DistributionGroupMember -Identity $GroupName -ResultSize Unlimited |select Name |export-csv C:\Users\salmo07\Desktop\output\$GroupName.csv -notypeinformation 
}
