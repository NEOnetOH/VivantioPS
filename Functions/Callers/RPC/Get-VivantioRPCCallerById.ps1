function Get-VivantioRPCCallerById {
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 0)]
        [uint32[]]$Id,
        
        [switch]$Raw
    )
    
    begin {
        
    }
    
    process {
        foreach ($i in $Id) {
            #$URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            #$uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            $Segments = [System.Collections.ArrayList]::new(@('Caller', 'SelectById', $i))
            $uri = BuildNewURI -Segments $Segments
            
            InvokeVivantioRequest -URI $uri -Raw:$Raw -Method POST
        }
    }
    
    end {
        
    }
}