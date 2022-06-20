
function New-VivantioRPCQuery {
<#
    .SYNOPSIS
        A brief description of the New-VivantioAPIQuery function.
    
    .DESCRIPTION
        A detailed description of the New-VivantioAPIQuery function.
    
    .PARAMETER Mode
        [VivantioQueryMode]$Mode,
    
    .PARAMETER Items
        A description of the Items parameter.
    
    .PARAMETER JSON
        A description of the JSON parameter.
    
    .EXAMPLE
        		PS C:\> New-VivantioAPIQuery -Mode 'MatchAll' -Items $value2
    
    .OUTPUTS
        pscustomobject, string
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([pscustomobject], ParameterSetName = 'Default')]
    [OutputType([string], ParameterSetName = 'JSON')]
    param
    (
        [Parameter(ParameterSetName = 'Default',
                   Mandatory = $true,
                   Position = 0)]
        [ValidateSet('MatchAll', 'MatchAny', 'MatchNone', IgnoreCase = $true)]
        [string]$Mode = 'MatchAll',
        
        [Parameter(ParameterSetName = 'Default',
                   Mandatory = $true,
                   Position = 1)]
        [pscustomobject[]]$Items,
        
        [Parameter(ParameterSetName = 'JSON')]
        [string]$JSON
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        "Default" {
            [pscustomobject]@{
                "Query" = [pscustomobject]@{
                    'Mode'  = $Mode
                    'Items' = $Items
                }
            }
        }
    }
}
