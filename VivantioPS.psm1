<#
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.206
	 Created on:   	2022-06-16 2:03 PM
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	VivantioPS.psm1
	-------------------------------------------------------------------------
	 Module Name: VivantioPS
	===========================================================================
#>


# Build a list of common parameters so we can omit them to build URI parameters
$script:CommonParameterNames = New-Object System.Collections.ArrayList
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::CommonParameters))
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
[void]$script:CommonParameterNames.Add('Raw')

SetupVivantioConfigVariable
Set-VivantioAPITimeout -TimeoutSeconds 60

#Export-ModuleMember -Function '*-*'


