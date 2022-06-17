<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckVivantioIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckVivantioIsConnected {
    [CmdletBinding()]
    param ()

    Write-Verbose "Checking connection status"
    if (-not $script:VivantioPSConfig.Connected) {
        throw "Not connected to a Vivantio API! Please run 'Connect-VivantioAPI'"
    }
}