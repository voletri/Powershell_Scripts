Dim messageText1, messageText2, servername, sharename, rggname, rlgname, rwggname, rwlgname

Const ADS_GROUP_TYPE_UNIVERSAL_GROUP = &h8
Const ADS_GROUP_TYPE_SECURITY_ENABLED = &H80000000

' Ask User Server and share names
messageText1 = InputBox("Please Enter the Server name for the share: ","Group Generator","USIL")
If messageText1 = "" Then
  wscript.quit
End if
messageText2 = InputBox("Please Enter the Share name: ","Group Generator","")
If messageText2 = "" Then
  wscript.quit
End if
messageText3 = InputBox("Please Enter a note: ","Group Generator","CR: - New Share Created")
If messageText3 = "" Then
  wscript.quit
End if


servername = ucase(messageText1)
sharename = messageText2
note = messageText3

' Read Group Variables
rggname = "GG " & servername & " " & sharename & " R"
rlgname = "LG " & servername & " " & sharename & " R"

' Read Write Group Variables
rwggname = "GG " & servername & " " & sharename & " RW"
rwlgname = "LG " & servername & " " & sharename & " RW"

' Read Global Group Creation
Set objOU = GetObject("LDAP://usildc04.ca.com/OU=groups,OU=North America,dc=ca,dc=com")
Set objGroup1 = objOU.Create("Group", "cn=" & rggname & "")
objGroup1.Put "sAMAccountName", "" & rggname & ""
objGroup1.Put "groupType", ADS_GROUP_TYPE_UNIVERSAL_GROUP or ADS_GROUP_TYPE_SECURITY_ENABLED
objgroup1.Description = "Read Access to share " & sharename & " on server " & servername & ""
objgroup1.info = note
objGroup1.SetInfo


' Read Local Group Creation
Set objOU = GetObject("LDAP://usildc04.ca.com/OU=groups,OU=North America,dc=ca,dc=com")
Set objGroup2 = objOU.Create("Group", "cn=" & rlgname & "")
objGroup2.Put "sAMAccountName", "" & rlgname & ""
objGroup2.Put "groupType", ADS_GROUP_TYPE_UNIVERSAL_GROUP or ADS_GROUP_TYPE_SECURITY_ENABLED
objGroup2.GroupType = -2147483644
objGroup2.Description = "Domain Local Group DO NOT ADD INDIVIDUAL USERS TO THIS GROUP"
objgroup2.info = note
objGroup2.SetInfo

' Add Read Local Group into Read Global Group
objGroup2.Add objGroup1.ADSPath

' Read Write Global Group Creation
Set objOU = GetObject("LDAP://usildc04.ca.com/OU=groups,OU=North America,dc=ca,dc=com")
Set objGroup3 = objOU.Create("Group", "cn=" & rwggname & "")
objGroup3.Put "sAMAccountName", "" & rwggname & ""
objGroup3.Put "groupType", ADS_GROUP_TYPE_UNIVERSAL_GROUP or ADS_GROUP_TYPE_SECURITY_ENABLED
objgroup3.Description = "Read Write Access to share " & sharename & " on server " & servername & ""
objgroup3.info = note
objGroup3.SetInfo

' Read Write Local Group Creation
Set objOU = GetObject("LDAP://usildc04.ca.com/OU=groups,OU=North America,dc=ca,dc=com")
Set objGroup4 = objOU.Create("Group", "cn=" & rwlgname & "")
objGroup4.Put "sAMAccountName", "" & rwlgname & ""
objGroup4.Put "groupType", ADS_GROUP_TYPE_UNIVERSAL_GROUP or ADS_GROUP_TYPE_SECURITY_ENABLED
objGroup4.GroupType = -2147483644
objGroup4.Description = "Domain Local Group DO NOT ADD INDIVIDUAL USERS TO THIS GROUP"
objgroup4.info = note
objGroup4.SetInfo

' Add Read Write Local Group into Read Write Global Group
objGroup4.Add objGroup3.ADSPath

msgbox "Groups created", ,"SUCCESS"