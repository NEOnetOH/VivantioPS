
function Get-VivantioRPCClientById {
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
        $Segments = [System.Collections.ArrayList]::new(@('Client', 'SelectById', $i))
    }
    
    process {
        foreach ($i in $Id) {
            #$URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            #$uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            $Segments[-1] = $i
            $uri = BuildNewURI -Segments $Segments
            
            InvokeVivantioRequest -URI $uri -Raw:$Raw -Method POST
            
            #Get-VivantioRPCData -Endpoint 'Client' -Method 'SelectById' -Value $i -Raw:$Raw
        }
    }
    
    end {
        
    }
}