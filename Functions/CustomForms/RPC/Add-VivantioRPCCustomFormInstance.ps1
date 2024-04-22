
function Add-VivantioRPCCustomFormInstance {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$ParentId,

        [Parameter(Mandatory = $true)]
        [uint64]$TypeId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Article', 'Asset', 'Caller', 'Client', 'Location', 'Ticket', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParentSystemArea,

        [Parameter(Mandatory = $true)]
        [pscustomobject[]]$FieldValues
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity', 'CustomEntityInsert'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = [pscustomobject]@{
            'ParentId'         = $ParentId
            'TypeId'           = $TypeId
            'ParentSystemArea' = $ParentSystemArea
            'FieldValues'      = [System.Collections.Arraylist]::new(@($FieldValues))
        } | ConvertTo-Json -Compress -Depth 100

        InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Method POST -Raw:$Raw
    }

    end {

    }
}






