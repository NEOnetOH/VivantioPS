
function Get-VivantioRPCCustomFormInstance {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [uint64]$TypeId,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [uint64]$ParentId,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [ValidateSet('Client', 'Location', 'Caller', 'Ticket', 'Asset', 'Article', IgnoreCase = $true)]
        [string]$SystemArea,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent')]
        [switch]$Simplified,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntitySelectById', $Id))
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
                
                break
            }
            
            'ByTypeIdAndParent' {
                if ($Simplified) {
                    [void]$Segments.Add('CustomEntitySimplifiedSelectByTypeIdAndParent')
                } else {
                    [void]$Segments.Add('CustomEntitySelectByTypeIdAndParent')
                }
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body @{
                    'TypeId'     = $TypeId
                    'ParentId'   = $ParentId
                    'SystemArea' = $SystemArea
                } -Method POST -Raw:$Raw
                
                break
            }
        }
    }
    
    end {
        
    }
}
