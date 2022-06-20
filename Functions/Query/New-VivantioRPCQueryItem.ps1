
function New-VivantioRPCQueryItem {
    [CmdletBinding()]
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
