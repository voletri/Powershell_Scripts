


$sharepath1="\\nasilcifs-generic\test"
$sharepath2="\\nasilcifs-generic\SOX-Treasury-Investment Mgmt A\"

$sharepath=$sharepath2.TrimEnd('\')
$sharepath=$sharepath.TrimStart('\\')

$GenericGroup=$sharepath -split '\\'

if($GenericGroup.count -eq 2){

$ServerName=$GenericGroup[0]
$ShareName=$GenericGroup[1]
$ownerName="salmo07"
$description=""

#Read Group Variables
$rggname = "GG $($servername) $($sharename) R"
$rlgname = "LG $($servername) $($sharename) R"

#Read Write Group Variables
$rwggname = "GG $($servername) $($sharename) RW"
$rwlgname = "LG $($servername) $($sharename) R"

$OU="Groups,OU=North America,dc=ca,dc=com"

NEW-ADGroup –name “Finance” –groupscope Global -GroupCategory Security –path $OU

}