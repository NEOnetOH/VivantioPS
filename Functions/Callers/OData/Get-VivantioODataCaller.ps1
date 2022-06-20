
function Get-VivantioODataCaller {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [string]$Filter,
        
        [uint16]$Skip,
        
        [switch]$All,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('Callers'))
    
    $Parameters = @{}
    
    if ($PSBoundParameters.ContainsKey('Filter')) {
        $Parameters['$filter'] = $Filter.ToLower().TrimStart('$filter=')
    }
    
    if ($PSBoundParameters.ContainsKey('Skip')) {
        $Parameters['$skip'] = $Skip
    }
    
    $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
    
#    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
#    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    $RawData = InvokeVivantioRequest -URI $uri -Raw -ErrorAction Stop
    
    $Callers = [pscustomobject]@{
        'TotalCallers' = $RawData.'@odata.count'
        '@odata.count' = $RawData.'@odata.count'
        '@odata.context' = $RawData.'@odata.context'
        '@odata.nextLink' = $RawData.'@odata.nextLink'
        'NumRequests'  = 1
        'value'        = [System.Collections.Generic.List[object]]::new()
    }
    
    [void]$Callers.value.AddRange($RawData.value)
    
    if ($All -and ($Callers.TotalCallers -gt 100)) {
        Write-Verbose "Looping to request all [$($Callers.TotalCallers)] results"
        
        # Determine how many requests we need to make. We can only obtain 100 at a time.
        $Remainder = 0
        $Callers.NumRequests = [math]::DivRem($Callers.TotalCallers, 100, [ref]$Remainder)
        
        if ($Remainder -ne 0) {
            # The number of callers is not divisible by 100 without a remainder. Therefore we need at least 
            # one more request to retrieve all callers. 
            $Callers.NumRequests++
        }
        
        Write-Verbose "Need to make $($Callers.NumRequests - 1) more requests"
        
        for ($RequestCounter = 1; $RequestCounter -lt $Callers.NumRequests; $RequestCounter++) {
            $PercentComplete = (($RequestCounter/$Callers.NumRequests) * 100)
            $paramWriteProgress = @{
                Id              = 1
                Activity        = "Obtaining Callers"
                Status          = "Request {0} of {1} ({2:N2}% Complete)" -f $RequestCounter, $Callers.NumRequests, $PercentComplete
                PercentComplete = $PercentComplete
            }
            
            Write-Progress @paramWriteProgress
            
            $Parameters['$skip'] = ($RequestCounter * 100)
            
            $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
            
            $Callers.value.AddRange((InvokeVivantioRequest -URI $uri -Raw).value)
        }
    }
    
    $Callers
}