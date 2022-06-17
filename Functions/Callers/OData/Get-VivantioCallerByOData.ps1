
function Get-VivantioCallerByOData {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [string]$Filter,
        
        [uint16]$Skip,
        
        [uint16]$Top,
        
        [switch]$Raw
    )
    
    $uriBuilder = [System.UriBuilder]::new()
    
    $Segments = [System.Collections.ArrayList]::new(@('Callers'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
    
    break
}