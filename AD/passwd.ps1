
Write-Host ""
Write-Host ""
Write-Host "Script Started at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

$InputFile="C:\temp\UserList.txt"

if(Test-Path $InputFile){

    $UserList = Get-Content $InputFile
    
    $E=$($UserList.count)
    $i=0

    Write-Host ""
    Write-Host "--------------------------------------------"
    Write-Host "Total Count of Generic UserID to be Processed - $E"
    Write-Host "--------------------------------------------"

    $NewPassword = "P@55word1"
    
    $Output=@()

    foreach($user in $UserList){

        $userDetails = {} | Select PMF,DisplayName,Status,ExpiryDate
        
        $o=$null
        
        try{
            $userDetails.PMF=$user

            $o=Get-ADUser $user –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed"|Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
            #Set-AdaccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
            $userDetails.Displayname=$o.Displayname
            $userDetails.ExpiryDate=$o.ExpiryDate

        }Catch [System.UnauthorizedAccessException] 
        {
           $userDetails.Status="Access Denied"

        }Catch [System.Exception]
        {
            $userDetails.Status="Unable to Reset the Password"
        }
        Catch
        {
            $userDetails.Status="Unable to Reset the Password"
        }

    
        finally
        {
        $userDetails
        $Output=$Output+$userDetails
        }    
    }


}else{

Write-Host "Input file Not found in the following path $($InputFile)" -ForegroundColor Red


}


Write-Host "Script Ended at - $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -foregroundcolor white -backgroundcolor Green

Write-Host "==============================================================================="

