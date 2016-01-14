##########################################################################################
<#
.NAME: AddUser-to-MultipleAD_ServerAdminGroups.ps1

.SYNOPSIS 
    Adds the User to Multiple Server AD Groups listed in InputFile

.PARAMETER User   
    PMFKey which needs to be added to the AD Groups

InputFile:
    1.Serverlist Should be placed in the following path C:\temp\ServerList.txt with the Servers List
        File should have ServerNames without .ca.com
    
    Example:
    usilasd00632
    usilasd00317

    2.Userlist Should be placed in the following path C:\temp\UserList.txt with the Users List
        File should have PMFKey
    Example:
    salmo07


.NOTES
    AD Powershell Module is Required to Run the Script
    
    Input Should be placed in the following path C:\temp\ServerList.txt with the Servers List
    Input File should have ServerNames without .ca.com
    
    Example:
    usilasd00632
    usilasd00317
    
    Run the Script as .\AddUser-to-MultipleAD_ServerAdminGroups.ps1 -User pmf

    AUTHOR: SALMO07
    LASTEDIT: June 4, 2015
    Developed on Powershell Version 4
#>
##########################################################################################


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

  
  $user="x"
    $a="true"

try{

    If(-not(Get-Module -Name ActiveDirectory))
    {
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

    $InputFile_Server="C:\temp\ServerList.txt"

    if(Test-Path $InputFile){
   
    $ServerList = Get-Content $InputFile

    $E=$($ServerList.count)
    $i=0

    Write-Host ""
    Write-Host "-----------------------------------------------------"
    Write-Host "$user needs to be added to $E Groups"
    Write-Host "-----------------------------------------------------"
    Write-Host ""
    
    $Output=@()

    $User=$User.Trim()

    $PMF_key = (Get-ADUser $User -Properties SamAccountName).SamAccountName

    
    foreach($Server in $ServerList){
        
        $Server=$Server.Trim()
        $Group="$($Server) Admin Global Group - ca.com"

        $GroupDetails = {} | Select PMF_key,Server,GroupName,Status
        
        $GroupDetails.PMF_key=$PMF_key

        $GroupDetails.GroupName=$Group
      
        try{

            if((Get-ADGroupMember $Group).name -notcontains $User){
            
                try{
                
                    #Add-ADGroupMember -Identity $Group -Members $User

                    if((Get-ADGroupMember $Group).name -contains $User){
                        
                        $GroupDetails.Status="Added Successfully"
                    
                    }else{
                        
                        $GroupDetails.Status="Unable to Add the User"
                    }
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
           }Catch [System.UnauthorizedAccessException] 
                {
                    $GroupDetails.Status="Access Denied"
                }
           Catch{               
                    $GroupDetails.Status="Unable to find the associated Group"
                }
        finally
        {
            Write-Host ""
                $GroupDetails
            Write-Host ""
            
            $Output=$Output+$GroupDetails
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

}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "==============================================================================="