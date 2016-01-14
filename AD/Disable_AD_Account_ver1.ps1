
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
    
    $AdminUserName="eTrustAdmin"
    $AdminPassword='Rasb3rry$tup1d'

    $InputFile_UserList="C:\temp\UserList.txt"

    if(Test-Path $InputFile_UserList){
   
        $UserList = Get-Content $InputFile_UserList
        $UserList ="idmup100"
        $E_UserList=$($UserList.count)

        $i=0

        Write-Host ""
        Write-Host "-----------------------------------------------------"
        Write-Host "$($E_UserList) Users neededs be to Proceesed"
        Write-Host "-----------------------------------------------------"
        Write-Host ""
    
        $Output=@()

        foreach($User in $UserList){
        
            $User=$User.Trim()
            $User ="idmup100"
            
            $UserDetails = {} | Select PMF_key,Status

            try{
                $UserDetails.PMF_key=$User

                $UserCheckPre = Get-ADUser $User -Properties ProtectedFromAccidentalDeletion |select SamAccountName,ProtectedFromAccidentalDeletion

                if($UserCheckPre.ProtectedFromAccidentalDeletion){

                   $AdminSecurePassword = ConvertTo-SecureString $AdminPassword -force -asPlainText 
                   $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "tant-a01\$AdminUserName",$AdminSecurePassword

                   Get-ADUser $User -Properties ProtectedFromAccidentalDeletion -Credential  $cred| Set-ADObject -ProtectedFromAccidentalDeletion:$False
                   
                   $UserCheckPost = Get-ADUser $User -Properties ProtectedFromAccidentalDeletion |select SamAccountName,ProtectedFromAccidentalDeletion

                    if($UserCheckPost.ProtectedFromAccidentalDeletion){                    
                    
                        $UserDetails.Status="Unable to Uncheck AccidentalDeletion"               
                
                    }else{
                    
                        $UserDetails.Status="Successfully Unchecked from AccidentalDeletion"           
                    } 

                }else{
                    $UserDetails.Status="Not Protected From Accidental Deletion"            
                }

            }Catch [System.UnauthorizedAccessException] 
                    {
                        $UserDetails.Status="Access Denied"
                    }
             Catch{               
                       $UserDetails.Status="User Not Found/Error"       

                    }

                 $Output=$Output+$UserDetails    

       }
               
        $OutputFile="C:\Temp\DisableUsers_$(get-date -f "yyyy-MM-dd_HH-mm-ss").csv"
    
        $Output|export-csv $OutputFile -NoTypeInformation

        Write-Host ""

        Write-Host "Output file is located  in the following path " -NoNewline
        Write-Host "$($OutputFile)" -ForegroundColor yellow

        Write-Host ""    

    }else{
    
            Write-Host ""
            Write-Host ""

            Write-Host "Input file is not found in the following path " -NoNewline -ForegroundColor Red
            Write-Host "$($InputFile_UserList)" -ForegroundColor yellow -BackgroundColor red
    
            Write-Host ""
            Write-Host ""   
    }

}

Write-Host ""
Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green
Write-Host ""
Write-Host "========================"