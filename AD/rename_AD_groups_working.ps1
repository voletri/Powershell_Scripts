
Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$a="true"

try{

    If(-not(Get-Module -Name ActiveDirectory))
    {
        Write-Host "Trying to Add Active Directory Module....." -ForegroundColor Green
        Import-Module -Name ActiveDirectory -ErrorAction Stop
    }
    
}catch{
    
    $a="false"

    Write-Host ""
    Write-Host ""

    write-host "You Need have AD Module to Run this Script" -foregroundcolor Red
    Write-Host ""
    Write-Host ""
}   

if($a){

    $InputFile_ShareList="C:\temp\NAS_ShareList.txt"

    if(Test-Path $InputFile_ShareList){
   
        $ShareList = Get-Content $InputFile_ShareList

        $OldShareServer="USILFS70"
        $NewShareServer="nasilcifs-test"

        foreach($Share in $ShareList){

            try
            {
                $OldShareGroup="GG cacifs30 OpenSystems RW "
                $OldShareGroup.trim()
                $OldShareGroupDetails=Get-ADGroup $OldShareGroup -Properties *|select CanonicalName,CN,Description,DistinguishedName,Name,SamAccountName

                #Renaming the SamAccountName
                $NewShareGroup_Name=$OldShareGroup -replace $OldShareServer,$NewShareServer
                Set-ADGroup -Identity $OldShareGroupDetails.SamAccountName -SamAccountName $NewShareGroup_Name
                
                #Renaming the Description
                $NewShareGroup_Description=$OldShareGroupDetails.Description -replace $OldShareServer,$NewShareServer
                Set-ADGroup -Identity $OldShareGroupDetails.SamAccountName -Description $NewShareGroup_Description
            
                #Renaming the DistinguishedName
                Rename-ADObject $OldShareGroupDetails.DistinguishedName -NewName $NewShareGroup_Name
                
                $NewShareGroupDetails=Get-ADGroup $NewShareGroup_Name -Properties CanonicalName,CN,Description,DistinguishedName,Name,SamAccountName|select CanonicalName,CN,Description,DistinguishedName,Name,SamAccountName     

            }

            catch
            {
                Write-Output "Error: $_" | Tee-Object  ADGroupBulkRenameLog.txt -Append
            }       
      }#Foreach Close

}else{
    
            Write-Host ""
            Write-Host ""

            Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
            Write-Host "$($InputFile_ShareList)" -ForegroundColor yellow -BackgroundColor red
    
            Write-Host ""
            Write-Host ""   
    }
}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "========================"

#Get-ADGroup $OldShareGroup -Properties * |select 