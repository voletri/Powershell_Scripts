##########################################################################################
<#
.NAME: AddUser-to-MultipleADGroups.ps1

.SYNOPSIS 
    Adds the User to Multiple Groups listed in InputFile

.PARAMETER User   
    PMFKey which needs to be added to the AD Groups

.NOTES
    AD Powershell Module is Required to Run the Script
    
    Input Should be placed in the following path C:\temp\GroupList.txt with the Groupslist
    
    Run the Script as .\AddUser-to-MultipleADGroups.ps1 -User pmf

    AUTHOR: SALMO07
    LASTEDIT: June 4, 2015
    Developed on Powershell Version 4
#>
##########################################################################################


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

try{

    If(-not(Get-Module -Name ActiveDirectory))
    {
        Import-Module -Name ActiveDirectory -ErrorAction Stop
    }  

   # $InputFile="C:\temp\ComputerList.txt"
    $InputFile="C:\temp\dc.txt"

    if(Test-Path $InputFile){
   
    $ComputerList = Get-Content $InputFile

    $E=$($ComputerList.count)
    $i=0

    Write-Host ""
    Write-Host "-----------------------------------------------------"
    Write-Host "Total Count of Groups to be Processed - $E"
    Write-Host "-----------------------------------------------------"
    Write-Host ""
    
    $Output=@()
    
    foreach($Computer in $ComputerList){
        
        #$Group="XD-intel-L2"
        $Group="XD-domain-admins"
        
        $Computer=$Computer.Trim()

        $GroupDetails = {} | Select Computer,GroupName,Status
        
        $GroupDetails.Computer=$Computer
        $GroupDetails.GroupName=$Group

        try{
           $computerCheck=$null                
           $computerCheck=Get-ADComputer $computer
           $c=$true
        }
        Catch
        {
           $GroupDetails.Status="Computer Account Not found"
            $c=$False
        }

    if($c){

        try{

            if((Get-ADGroupMember $Group).name -notcontains $Computer){
            
                try{
                
                    Add-ADGroupMember -Identity $Group -Members $($computerCheck.SamAccountName)
                    $GroupDetails.Status="Added Successfully"
                }
                Catch [System.UnauthorizedAccessException] 
                {
                    $GroupDetails.Status="Access Denied"
                }
                Catch{               
                    $GroupDetails.Status="Unable to ADD"
                }
            
            }else{
                
                $GroupDetails.Status="User Already has Access"
            
            }
       }
       Catch [System.UnauthorizedAccessException] 
                {
                    $GroupDetails.Status="Access Denied"
                }
       Catch{               
                    $GroupDetails.Status="Unable to find the associated Group"
                }
       finally{
            
            Write-Host ""
            $GroupDetails
            Write-Host ""
            $Output=$Output+$GroupDetails
        }
     }       
    }
    
    $OutputFile="C:\Temp\Bulk_GroupMemberAddition_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"
    
    $Output|export-csv $OutputFile -NoTypeInformation

    Write-Host ""    
    Write-Host ""

    Write-Host "Output file is located  in the following path " -NoNewline
    Write-Host "$($OutputFile)" -ForegroundColor yellow

    Write-Host ""    
    Write-Host ""


}else{

    Write-Host ""
    Write-Host ""

    Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
    Write-Host "$($InputFile)" -ForegroundColor yellow

    Write-Host ""
    Write-Host ""
}

}catch{
    
    Write-Host ""
    Write-Host ""

    write-host "You Need have AD Module to Run this Script" -foregroundcolor Red
    Write-Host ""
    Write-Host ""
}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "==============================================================================="