
function Get-VivantioRPCCustomFormDefinition {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(ParameterSetName = 'ByRecordTypeId',
                   Mandatory = $true)]
        [uint64]$RecordTypeId,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntityDefinitionSelectById', $Id))
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
                
                break
            }
            
            'ByRecordTypeId' {
                [void]$Segments.Add('CustomEntityDefinitionSelectByRecordTypeId')
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body @{'Id' = $RecordTypeId} -Method POST
                
                break
            }
        }
    }
    
    end {
        
    }
}
