#alan dot kaplan at va dot gov
#7-26-2013
#Gets list of inactive computers based on last password change
#you can navigate to OU to choose start.

$reqVer = 3
if ((get-host).version.major -lt $reqVer) {
	Write-Error "This script requires Powershell $reqVer or later."
	pause
	Exit-PSSession
}

$ActiveDays = 90
$scriptName= GCI $MyInvocation.InvocationName | % {$_.BaseName}
#Designed for testing, you can change this value to a number to restrict
#the number of items returned
#$ReturnLimit = 10
$ReturnLimit = $null

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')  

Import-Module ActiveDirectory

#OU selection Functions
Function NavOU  { param([string] $adsPath)
    # onelevel for speed.  $server is a GC 
    $a = Get-ADOrganizationalUnit -searchscope OneLevel -server $server -searchbase $adsPath -Filter 'Name -like "*"' `
    | Select-Object -Property name, distinguishedname | ogv -OutputMode Single -Title "Select an OU and click OK"
    
    if ($a.length -eq 0) {Exit}

    $global:adsPath = ($a).distinguishedname
    $Message = 'The currently selected path is ' + ($a).distinguishedname  + '. Continue Navigation? (No starts with this path)'

    $retval = [Microsoft.VisualBasic.Interaction]::MsgBox($Message,'YesNo,systemmodal,Question',"Continue Search")

    if ($retval -eq  'Yes') {NavOU ($a).distinguishedname}
}


Function GetAdsPath(){
    $adDomain = Get-AdDomain
    $message = "This will allow you to navigate to choose a OU to search.  Begin by choosing a starting Domain:"
    $DomName = [Microsoft.VisualBasic.Interaction]::InputBox($Message, "Domain Name", $adDomain.dnsroot )
    if ($Domname.Length -eq 0)   {Exit}

    if ($adDomain.dnsroot -ne $domName){
       $adDomain = Get-AdDomain $domname
       $gc = get-addomaincontroller -server $DomName -Filter { isGlobalCatalog -eq $true}
       $Global:server = $gc.Item(0).HostName
    }
    else {
        $global:Server = $adDomain.InfrastructureMaster
    }
    
    $adspath = $adDomain.DistinguishedName
    #Write-Host $Server
   
    $Message = 'Do you want to select an Organizational Unit of ' + $adspath + '?'
    $retval = [Microsoft.VisualBasic.Interaction]::MsgBox($Message,'YesNo,systemmodal,Question','Navigate OU Structure?')

    if ($retval -eq  'Yes') {  
        #Initial Path
        navOU $adsPath   
    }
        else {
        $global:adsPath = $adDomain.DistinguishedName
    }
}

$message = "This script will return information about inactive `
computers based on the date the password was last set. Continue?"

$retval = [Microsoft.VisualBasic.Interaction]::MsgBox($message,'YesNo,Question',"Welcome")
if ($retval -eq 'No') {Exit}

$ActiveDays = [Microsoft.VisualBasic.Interaction]::InputBox("Look for computers who have a password change more than this many days:",`
 "Days", "$ActiveDays")
if ($ActiveDays.Length -eq 0)   {Exit}

$outfile = $env:userprofile+"\desktop\"+ $scriptName + ".csv"
$outfile = [Microsoft.VisualBasic.Interaction]::InputBox("Write CSV results file to what path", "Report file", "$outfile")
if ($outfile.Length -eq 0)   {Exit}

getAdsPath

$searchpath= $adsPath.Trim()

#work begins here

$lastSetdate = [DateTime]::Now - [TimeSpan]::Parse($iDays)
$computers = Get-ADComputer -Filter {PasswordLastSet -le $lastSetdate} `
-Properties samaccountname,passwordLastSet -SearchBase $searchPath -ResultSetSize $returnlimit
$Computers | Select-Object -Property Name,PasswordLastSet,`
@{Name="Elapsed Days"; Expression ={$t=new-timespan -start $_.PasswordLastSet -end (get-date);$t.Days}}, `
DistinguishedName | Export-Csv -Path $outfile -notype
ii $outfile