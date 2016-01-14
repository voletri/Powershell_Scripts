
$SID="S-1-5-21-2129867641-919698055-327642922-629535"

$objSID = New-Object System.Security.Principal.SecurityIdentifier ($profile.sid)
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value


