
function Set-VivantioRPCCustomForm {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(Mandatory = $true)]
        [psobject[]]$FieldValues
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity', 'CustomEntityUpdate'))
    }
    
    process {
        $uri = BuildNewURI -Segments $Segments
        
        $Body = [pscustomobject]@{
            'Id'          = $Id
            'FieldValues' = [System.Collections.Arraylist]::new(@($FieldValues))
        } | ConvertTo-Json -Compress -Depth 100
        
        InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Method POST -Raw:$Raw
    }
    
    end {
        
    }
}
