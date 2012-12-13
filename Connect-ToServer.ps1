<#
.SYNOPSIS
Connects to a remote machine.

.DESCRIPTION
A wrapper for connecting to remote servers via PSSession. It includes the parameters for authentication and credentials.

.PARAMETER Server
The server to which you wish to connect.
#>
param (
    [Parameter(Position=1, Mandatory=$true)]
    [string] $Server
)

Enter-PSSession -ComputerName $Server -Credential $(Get-Credential) -Authentication Credssp
