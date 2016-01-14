
usilst65
(New-Object Net.Sockets.TcpClient).Connect("usilapadfs1",445)

<#


Firewalls, PowerShell and "The rpc server is unavailable"
Security experts will hold up the hands in horror at this suggestion, but if you get the error message: "The rpc server is unavailable", then I suggest that you turn off the firewall on both machines.
Now if that works, then great, but follow-up by testing which ports are involved (135, 445), then try configuring the firewall with exceptions that allow PowerShell remoting, but retain firewall protection from other threats.
See how to disable a Windows 8 firewall with a Group Policy.
P.S. I have read that Enable-PSRemoting is supposed to take care of the firewall settings automatically, but in my experience this was not always the case.

#>