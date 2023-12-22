
function New-VivantioRPCCustomFormFieldValue {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$FieldId,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    [pscustomobject]@{
        'FieldId' = $FieldId
        'Value' = $Value
    }
}





