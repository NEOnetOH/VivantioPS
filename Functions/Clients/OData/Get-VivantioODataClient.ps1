
function Get-VivantioODataClient {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [string]$Filter,
        
        [uint16]$Skip,
        
        [switch]$All,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('Clients'))
    
    $Parameters = @{}
    
    if ($PSBoundParameters.ContainsKey('Filter')) {
        $Parameters['$filter'] = $Filter.ToLower().TrimStart('$filter=')
    }
    
    if ($PSBoundParameters.ContainsKey('Skip')) {
        $Parameters['$skip'] = $Skip
    }
    
    $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
    
    $paramWriteProgress = @{
        Id              = 1
        Activity        = "Obtaining Clients"
        Status          = "Request 1 of ?"
        PercentComplete = 1
    }
    
    Write-Progress @paramWriteProgress
    $RawData = InvokeVivantioRequest -URI $uri -Raw -ErrorAction Stop
    
    # Create a Clients object to mimic the OData return object with some additional properties
    $Clients = [pscustomobject]@{
        'TotalClients' = $RawData.'@odata.count'
        '@odata.count' = $RawData.'@odata.count'
        '@odata.context' = $RawData.'@odata.context'
        '@odata.nextLink' = $RawData.'@odata.nextLink'
        'NumRequests'  = 1
        'value'        = [System.Collections.Generic.List[object]]::new()
    }
    
    [void]$Clients.value.AddRange($RawData.value)
    
    if ($All -and ($Clients.TotalClients -gt 100)) {
        Write-Verbose "Looping to request all [$($Clients.TotalClients)] results"
        
        # Determine how many requests we need to make. We can only obtain 100 at a time.
        $Remainder = 0
        $Clients.NumRequests = [math]::DivRem($Clients.TotalClients, 100, [ref]$Remainder)
        
        if ($Remainder -ne 0) {
            # The number of Clients is not divisible by 100 without a remainder. Therefore we need at least 
            # one more request to retrieve all Clients. 
            $Clients.NumRequests++
        }
        
        Write-Verbose "Need to make $($Clients.NumRequests - 1) more requests"
        
        for ($RequestCounter = 1; $RequestCounter -lt $Clients.NumRequests; $RequestCounter++) {
            $PercentComplete = (($RequestCounter/$Clients.NumRequests) * 100)
            $paramWriteProgress = @{
                Id              = 1
                Activity        = "Obtaining Clients"
                Status          = "Request {0} of {1} ({2:N2}% Complete)" -f $RequestCounter, $Clients.NumRequests, $PercentComplete
                PercentComplete = $PercentComplete
            }
            
            Write-Progress @paramWriteProgress
            
            $Parameters['$skip'] = ($RequestCounter * 100)
            
            $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
            
            $RawData = InvokeVivantioRequest -URI $uri -Raw
            $Clients.'@odata.nextLink' = $RawData.'@odata.nextLink'
            $Clients.value.AddRange($RawData.value)
        }
    }
    
    Write-Progress @paramWriteProgress -Completed
    
    $Clients
}




