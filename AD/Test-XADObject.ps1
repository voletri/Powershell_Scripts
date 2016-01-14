function Test-XADObject() {
   2:   
   3:     [CmdletBinding(ConfirmImpact="Low")]
   4:   
   5:     Param (
   6:   
   7:        [Parameter(Mandatory=$true,
   8:   
   9:                   Position=0,
  10:   
  11:                   ValueFromPipeline=$true,
  12:   
  13:                   HelpMessage="Identity of the AD object to verify if exists or not."
  14:   
  15:                  )]
  16:   
  17:        [Object] $Identity
  18:   
  19:     )
  20:   
  21:     trap [Exception] {
  22:   
  23:        return $false
  24:   
  25:     }
  26:   
  27:     $auxObject = Get-ADObject -Identity $Identity
  28:   
  29:     return $true
  30:   
  31:  }