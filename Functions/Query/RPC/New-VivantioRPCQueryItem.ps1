
function New-VivantioRPCQueryItem {
<#
    .SYNOPSIS
        Generate a hashtable query item for an RPC API query

    .DESCRIPTION
        Generate a hashtable query item for an RPC API query

    .PARAMETER FieldName
        The name of the field for filtering

    .PARAMETER Operator
        How the match will operate
        [Equals | DoesNotEqual | GreaterThan | GreaterThanOrEqualTo | LessThan | LessThanOrEqualTo | Like]

    .PARAMETER Value
        The value to match

    .EXAMPLE
        PS C:\> New-VivantioRPCQueryItem -FieldName 'Email' -Operator Equals -Value 'user@domain.com'

    .EXAMPLE
        PS C:\> New-VivantioRPCQueryItem 'Email' Equals 'user@domain.com'

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [string]$FieldName,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Equals', 'DoesNotEqual', 'GreaterThan', 'GreaterThanOrEqualTo', 'LessThan', 'LessThanOrEqualTo', 'Like', IgnoreCase = $true)]
        [string]$Operator,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        [string]$Value
    )

    [pscustomobject]@{
        'FieldName' = $FieldName
        'Op'        = $Operator
        'Value'     = $Value
    }
}
