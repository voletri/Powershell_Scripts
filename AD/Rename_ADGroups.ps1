<#
  .SYNOPSIS
  rename Active Directory group(s)
  .DESCRIPTION
  rename single Active Directory group or several groups from an input file
  .EXAMPLE
  RenameADGroups.ps1 -UseFile:$true -InputFile "PathToInputfile"
  With -UseFile:$true you also need a value for -InputFile "PathToInputfile" 
  .EXAMPLE
  RenameADGroups.ps1 -UseFile:$false
  the script prompts for the input of old and new groupname
  .PARAMETER UseFile
  $true = Path to Inputfile is required
  $false [Default]
  .PARAMETER InputFile
  InputFile = "PathToInputfile" in the form: 
  "OldGroupname -Delim NewGroupname"
  .PARAMETER Delim
  Default Delimiter is ";"
  .PARAMETER Confirm
  $true = [Default] each group rename must be confirmed 
  .NOTES
  Author: Manfred Paleit
  Version: 1.0
  Date: Nov 2013
  .Link
  www.tools4net.de
#>

PARAM(
	$UseFile = $false,
	$InputFile = "does_not_exist",
	$Delim = ";",
	$Confirm = $true
)

import-module	ActiveDirectory


function Get-ScriptDirectory {
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}
$ScriptPath = Get-ScriptDirectory 

$outFile = $ScriptPath + "\RenameADGroup.txt"
$logFile = $ScriptPath + "\RenameADGroup.log"
$CRLF = "`r`n"
$TAB = "	"

Function ProcessInput {
	[STRING](Get-Date) | Set-Content -Path $LogFile -encoding ASCII
	If ($UseFile) {
		If ( (Test-Path $InputFile) -eq $false ) {
			"ERROR InputFile not found" + $TAB + $InputFile | Add-Content -Path $LogFile -encoding ASCII
			"ERROR InputFile not found" + $TAB + $InputFile
			exit 
		}
		"old Name" + $TAB + "new Name" + $TAB + "Status"  | Set-Content -Path $outFile -encoding ASCII
		ProcessInputFile $InputFile
	} else {
		while ($true) {	GetGroupName }
	}
}	

Function GetGroupName {
	$old = Read-Host "old Groupname?"
	if ($old -eq "") {
		"Groupname required - Script will quit"
		exit
	}	
	$new = Read-Host "new Groupname?"	
	if ($new -eq "") {
		"Groupname required - Script will quit"
		exit
	}	
	RenameGroup $old $new $true
}

Function ProcessInputFile {
	Param (
		$file
	)
	"Reading $file - please wait ..."
	$groups = Get-Content $file
	foreach ($line in $groups) {
		$arr = $line.Split($Delim)	
		$old = ($arr[0]).Trim()
		$new = ($arr[1]).Trim()
		if ($old -like "*cn=*") { #der DN muss gesplittet werden
			$arr = $old.Split(",")
			$old = @($arr[0].split("="))[1]
		}
		if ($new -like "*cn=*") { #der DN muss gesplittet werden
			$arr = $new.Split(",")
			$new = @($arr[0].split("="))[1]
		}
		RenameGroup $old $new $Script:Confirm
	}
}

Function RenameGroup {
	Param (
	$oldname,
	$newname,
	$confirm
	)

	If ($confirm) {
		""
		$q = Read-Host "Rename '$oldname' in '$newname' (y/n)?"	
		if ( $q.ToLower() -ne "y" ) { return }
	}
	
	Try {
		$g = Get-ADGroup $oldname -ea stop
	} Catch {
		"ERROR getting Group" + $TAB + $oldname	+ $TAB + ($_.Exception.ToString()).Replace($CRLF,"") | Add-Content -Path $LogFile -encoding ASCII
		"ERROR getting Group" + $TAB + $oldname	
		return
	}
	
	Try {
		Set-ADGroup -Identity $g -SamAccountName $newname -ea stop
		Rename-ADObject -Identity $g -NewName $newname -ea stop
		$oldname + $TAB + $newname + $TAB + "ok" | Add-Content -Path $outFile -encoding ASCII
		$oldname + $TAB + $newname + $TAB + "ok"
	} Catch {
		$oldname + $TAB + $newname + $TAB + ($_.Exception.ToString()).Replace($CRLF,"") | Add-Content -Path $outFile -encoding ASCII
	}
}

ProcessInput