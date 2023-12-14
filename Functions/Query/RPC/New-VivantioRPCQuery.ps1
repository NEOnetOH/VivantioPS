
function New-VivantioRPCQuery {
<#
    .SYNOPSIS
        Generates a hashtable of query items to feed to an RPC API query.
    
    .DESCRIPTION
        Generates a hashtable of query items to feed to an RPC API query.
    
    .PARAMETER Mode
        What type of matching the query will do [MatchAll | MatchAny | MatchNone]
    
    .PARAMETER Items
        A collection of QueryItems from New-VivantioRPCQueryItem
    
    .EXAMPLE
        PS C:\> New-VivantioAPIQuery 
                -Mode 'MatchAll' 
                -Items (New-VivantioRPCQuery -Mode MatchAll -Items (New-VivantioRPCQueryItem -FieldName 'email' -Operator Equals -Value 'user@domain.com'))
    
    .EXAMPLE
        PS C:\> New-VivantioAPIQuery 'MatchAll' $Items
    
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
        [pscustomobject[]]$Items
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
