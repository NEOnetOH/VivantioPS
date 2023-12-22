
function Get-VivantioRPCCustomFormFieldDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$Id,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }

    process {
        [void]$Segments.AddRange(@('CustomEntityFieldDefinitionSelectById', $Id))

        $uri = BuildNewURI -Segments $Segments

        InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
    }

    end {

    }
}
