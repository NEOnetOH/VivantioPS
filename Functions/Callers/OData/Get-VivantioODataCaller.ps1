
function Get-VivantioODataCaller {
<#
    .SYNOPSIS
        Get caller data from OData
    
    .DESCRIPTION
        A detailed description of the Get-VivantioODataCaller function.
    
    .PARAMETER Filter
        The filter to use for OData. 
        
        NOTE: Filtering is extremely limited for OData as the OData interface is not fully developed at Vivantio
    
    .PARAMETER Skip
        Number of items to skip
    
    .PARAMETER All
        Enable to obtain all items in the query instead of only the first page
    
    .PARAMETER Raw
        Return the raw request data instead of results only
    
    .EXAMPLE
        PS C:\> Get-VivantioODataCaller
    
    .NOTES
        Additional information about the function.
#>
    
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
    } else {
        $Parameters['$skip'] = 0
    }
    
    $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
    
    $paramWriteProgress = @{
        Id              = 1
        Activity        = "Obtaining Callers"
        Status          = "Request 1 of ?"
        PercentComplete = 1
    }
    
    Write-Progress @paramWriteProgress
    Write-Verbose "Obtaining initial page of data"
    $RawData = InvokeVivantioRequest -URI $uri -Raw -ErrorAction Stop
    Write-Verbose "Retrieved [$($RawData.value.count)] results"
    
    # Create a callers object to mimic the OData return object with some additional properties
    $Callers = [pscustomobject]@{
        'TotalCallers' = $RawData.'@odata.count'
        '@odata.count' = $RawData.'@odata.count'
        '@odata.context' = $RawData.'@odata.context'
        '@odata.nextLink' = $RawData.'@odata.nextLink'
        'NumRequests'  = 1
        'value'        = [System.Collections.Generic.List[object]]::new()
    }
    
    [void]$Callers.value.AddRange($RawData.value)
    
#    $SkipAndValuesMatch = Test-VivantioODataResultsCountMatchNextURLSkipParameter -NextLink $Callers.'@odata.nextLink' -Values $RawData.value -DetailedResults
#    
#    if (-not $SkipAndValuesMatch.Matches) {
#        Write-Warning $("NextLink skip value [{0}] DOES NOT MATCH result count [{1}]" -f $SkipAndValuesMatch.SkipValue, $SkipAndValuesMatch.ValueCount)
#    }
    
    if ($All -and ($Callers.TotalCallers -gt $RawData.value.Count)) {
        Write-Verbose "Looping to request all [$($Callers.TotalCallers)] results"
        
        # Determine how many requests we need to make
        # Check the value count to request the next X amount
        $Remainder = 0
        $Callers.NumRequests = [math]::DivRem($Callers.TotalCallers, $RawData.value.count, [ref]$Remainder)
        
        if ($Remainder -ne 0) {
            # The number of callers is not divisible by $RawData.value.count without a remainder. Therefore we need at least 
            # one more request to retrieve all callers. 
            $Callers.NumRequests++
        }
        
        Write-Verbose "Need to make $($Callers.NumRequests - 1) more requests"
        
        for ($RequestCounter = 1; $RequestCounter -lt $Callers.NumRequests; $RequestCounter++) {
            Write-Verbose "Request $($RequestCounter + 1) of $($Callers.NumRequests)"
            
            $PercentComplete = (($RequestCounter/$Callers.NumRequests) * 100)
            $paramWriteProgress = @{
                Id              = 1
                Activity        = "Obtaining Callers"
                Status          = "Request {0} of {1} ({2:N2}% Complete)" -f $RequestCounter, $Callers.NumRequests, $PercentComplete
                PercentComplete = $PercentComplete
            }
            
            Write-Progress @paramWriteProgress
            
            $Parameters['$skip'] = ($RequestCounter * $RawData.value.count)
            
            $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters
            
            $RawData = InvokeVivantioRequest -URI $uri -Raw
            Write-Verbose "Retrieved [$($RawData.value.count)] results"
            
            $Callers.'@odata.nextLink' = $RawData.'@odata.nextLink'
            $Callers.value.AddRange($RawData.value)
        }
    }
    
    Write-Progress @paramWriteProgress -Completed
    
    $Callers
}



