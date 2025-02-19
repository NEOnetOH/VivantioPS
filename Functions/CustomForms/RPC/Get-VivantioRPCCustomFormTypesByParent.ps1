function Get-VivantioRPCCustomFormTypesByParent {
  [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$ParentId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Client', 'Location', 'Caller', 'Ticket', 'Asset', 'Article', IgnoreCase = $true)]
        [string]$SystemArea,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity', 'SelectEntityTypeIdsByParentItem'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        InvokeVivantioRequest -URI $uri -Body @{
            'ParentId'   = $ParentId
            'SystemArea' = $SystemArea
        } -Method POST -Raw:$Raw
    }

    end {

    }
}