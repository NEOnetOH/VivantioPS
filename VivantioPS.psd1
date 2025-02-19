﻿#
# Module manifest for module 'VivantioPS'
#
# Generated by: Ben Claussen
#
# Generated on: 2025-02-19
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'VivantioPS.psm1'

# Version number of this module.
ModuleVersion = '1.5.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '2ec329f1-0d52-4cdb-ada0-adacdd6dc584'

# Author of this module
Author = 'Ben Claussen'

# Company or vendor of this module
CompanyName = 'NEOnet'

# Copyright statement for this module
Copyright = '(c) 2022. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Provides functions to interface with VivantioAPI'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
DotNetFrameworkVersion = '2.0'

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
CLRVersion = '2.0.50727'

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-VivantioRPCCustomFormInstance',
               'Add-VivantioRPCTicketAttachment', 'Add-VivantioRPCTicketNote',
               'Clear-VivantioAPICredential', 'Clear-VivantioAPIProxy',
               'Close-VivantioRPCTicket', 'Connect-VivantioAPI',
               'Get-VivantioAPICredential', 'Get-VivantioAPITimeout',
               'Get-VivantioODataCaller', 'Get-VivantioODataClient',
               'Get-VivantioODataURI', 'Get-VivantioODataURIHost',
               'Get-VivantioODataURIPort', 'Get-VivantioODataURIScheme',
               'Get-VivantioRPCAttachment', 'Get-VivantioRPCAttachmentByParent',
               'Get-VivantioRPCCaller', 'Get-VivantioRPCClient',
               'Get-VivantioRPCCustomFormDefinition',
               'Get-VivantioRPCCustomFormFieldDefinition',
               'Get-VivantioRPCCustomFormInstance',
               'Get-VivantioRPCCustomFormTypesByParent',
               'Get-VivantioRPCEmailTemplate', 'Get-VivantioRPCTicket',
               'Get-VivantioRPCTicketType', 'Get-VivantioRPCURI',
               'Get-VivantioRPCURIHost', 'Get-VivantioRPCURIPort',
               'Get-VivantioRPCURIScheme', 'Get-VivantioRPCUser',
               'New-VivantioODataFilter', 'New-VivantioRPCCustomFormFieldValue',
               'New-VivantioRPCQuery', 'New-VivantioRPCQueryItem',
               'New-VivantioRPCTicket', 'New-VivantioRPCTicketUpdateRequest',
               'Set-VivantioAPICredential', 'Set-VivantioAPIProxy',
               'Set-VivantioAPITimeout', 'Set-VivantioODataHost',
               'Set-VivantioODataURI', 'Set-VivantioODataURIPort',
               'Set-VivantioODataURIScheme', 'Set-VivantioRPCCustomForm',
               'Set-VivantioRPCTicket', 'Set-VivantioRPCTicketStatus',
               'Set-VivantioRPCURI', 'Set-VivantioRPCURIHost',
               'Set-VivantioRPCURIPort', 'Set-VivantioRPCURIScheme',
               'Test-VivantioODataResultsCountMatchNextURLSkipParameter'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Vivantio','API'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/NEOnetOH/VivantioPS'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

