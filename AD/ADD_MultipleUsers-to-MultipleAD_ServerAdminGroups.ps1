##########################################################################################
<#

.NAME: Add_MultipleUsers-to-MultipleAD_ServerAdminGroups.ps1

.SYNOPSIS 
    Adds Multiple Users to Multiple Server AD Groups listed in InputFiles

InputFile:
    
    1.Serverlist Should be placed in the following path C:\temp\AD_ServerList.txt with the Servers List
        InputFile should have ServerNames without .ca.com
    
        Example:
            usilasd00632
            usilasd00317

    2.Userlist Should be placed in the following path C:\temp\AD_UserList.txt with the Users List
        InputFile should have PMFKey
    
        Example:
            salmo07

.NOTES
    AD Powershell Module is Required to Run the Script
        
    Run the Script as .\Add_MultipleUsers-to-MultipleAD_ServerAdminGroups.ps1

    AUTHOR: SALMO07
    LASTEDIT: June 15, 2015
    Developed on Powershell Version 4
#>
##########################################################################################


Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

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

    $InputFile_ServerList="C:\temp\AD_ServerList.txt"
    $InputFile_UserList="C:\temp\AD_UserList.txt"


    if((Test-Path $InputFile_ServerList) -and (Test-Path $InputFile_UserList)){
   
        $ServerList = Get-Content $InputFile_ServerList
        $UserList = Get-Content $InputFile_UserList

        $E_ServerList=$($ServerList.count)
        $E_UserList=$($UserList.count)

        $i=0

        Write-Host ""
        Write-Host "-----------------------------------------------------"
        Write-Host "$($E_UserList) Users needed be to added to $($E_ServerList) Groups"
        Write-Host "-----------------------------------------------------"
        Write-Host ""
    
        $Output=@()

        foreach($User in $UserList){
        
            $User=$User.Trim()
                
            $PMF_key=$null
            $PMF_key = (Get-ADUser $User -Properties SamAccountName).SamAccountName

            foreach($Server in $ServerList){
        
                $Server=$Server.Trim()
                
                $Group="$($Server) Admin Global Group - ca.com"

                $GroupDetails = {} | Select PMF_key,Server,GroupName,Status
        

                if($PMF_key -ne $null){
                    
                    $GroupDetails.PMF_key=$PMF_key
                    $GroupDetails.Server=$Server
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
                                $GroupDetails.Status="Unable to ADD: Error"
                            }
            
                        }else{
                
                            $GroupDetails.Status="User Already has Access"
            
                        }
                    }Catch [System.UnauthorizedAccessException] 
                    {
                        $GroupDetails.Status="Access Denied"
                    }
                    Catch{               
                        $GroupDetails.Status="Unable to find the Associated AD Group"
                    }
            }else{
                    $GroupDetails.PMF_key=$User
                    $GroupDetails.Server=$Server
                    $GroupDetails.Status="User Not Found"       
                }
        
                Write-Host ""
                    $GroupDetails
                                   
                
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

        if(!(Test-Path $InputFile_ServerList)){ 
    
            Write-Host ""
            Write-Host ""

            Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
            Write-Host "$($InputFile_ServerList)" -ForegroundColor yellow -BackgroundColor red

            Write-Host ""
            Write-Host ""
    
        }

        if(!(Test-Path $InputFile_UserList)){ 
    
            Write-Host ""
            Write-Host ""

            Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
            Write-Host "$($InputFile_UserList)" -ForegroundColor yellow -BackgroundColor red
    
            Write-Host ""
            Write-Host ""   
        }
    }

}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "==============================================================================="