
function Test-VivantioODataResultsCountMatchNextURLSkipParameter {
    [CmdletBinding(DefaultParameterSetName = 'BooleanResult')]
    [OutputType([boolean], ParameterSetName = 'BooleanResult')]
    [OutputType([pscustomobject], ParameterSetName = 'DetailedResults')]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$NextLink,
        
        [Parameter(Mandatory = $true)]
        [object[]]$Values,
        
        [Parameter(ParameterSetName = 'DetailedResults')]
        [switch]$DetailedResults
    )
    
    Write-Verbose "Testing result count matches skip parameter"
    
    try {
        $URIBuilder = [System.UriBuilder]::new($NextLink)
    } catch {
        throw "Cannot convert link to URI: $($_.Exception.Message)"
    }
    
    try {
        $QueryParameters = [System.Web.HttpUtility]::ParseQueryString($URIBuilder.Query)
    } catch {
        throw "Failed to parse query string [$($URIBuilder.Query)]: $($_.Exception.Message)"
    }
    
    if ($QueryParameters -inotcontains '$skip') {
        throw "Query does not contain a '`$skip' parameter"
    }
    
    $Assertion = $QueryParameters['$skip'] -eq @($Values).Count
    
    Write-Verbose "Skip value = $($QueryParameters['$skip']) | Values count = $(@($Values).Count)"
    
    switch ($PSCmdlet.ParameterSetName) {
        'BooleanResult' {
            return $Assertion
        }
        
        'DetailedResults' {
            [pscustomobject]@{
                'Matches'         = $Assertion
                'NextLink'        = $NextLink
                'SkipValue'       = $QueryParameters['$skip']
                'ValueCount'      = $Values.Count
                'URIBuilder'      = $URIBuilder
                'QueryParameters' = $QueryParameters
            }
        }
    }
}




