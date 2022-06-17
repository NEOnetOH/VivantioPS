
function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Vivantio
    
    .DESCRIPTION
        Internal function used to build a URIBuilder object.
    
    .PARAMETER APIType
        A description of the APIType parameter.
    
    .PARAMETER Segments
        Array of strings for each segment in the URL path
    
    .PARAMETER Parameters
        Hashtable of query parameters to include
    
    .PARAMETER SkipConnectedCheck
        A description of the SkipConnectedCheck parameter.
    
    .PARAMETER Hostname
        Hostname of the Vivantio API
    
    .PARAMETER HTTPS
        Whether to use HTTPS or HTTP
    
    .PARAMETER Port
        A description of the Port parameter.
    
    .PARAMETER APIInfo
        A description of the APIInfo parameter.
    
    .EXAMPLE
        PS C:\> BuildNewURI
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param
    (
        [ValidateSet('API', 'OData', IgnoreCase = $true)]
        [string]$APIType = 'API',
        
        [Parameter(Mandatory = $false)]
        [string[]]$Segments,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters,
        
        [switch]$SkipConnectedCheck
    )
    
    Write-Verbose "Building URI"
    
    if (-not $SkipConnectedCheck) {
        # There is no point in continuing if we have not successfully connected to an API
        $null = CheckVivantioIsConnected
    }
    
    # Create a new URIBuilder from our pre-configured URIs
    # If you simply assign $script:VivantioPSConfig.URI.RPC, you will then directly modify the original
    $uriBuilder = if ($APIType -eq 'API') {
        [System.UriBuilder]::new($script:VivantioPSConfig.URI.RPC.ToString())
    } else {
        [System.UriBuilder]::new($script:VivantioPSConfig.URI.OData.ToString())
    }
    
    # Generate the path by trimming excess slashes and whitespace from the $segments[] and joining together
    $uriBuilder.Path = "{0}/{1}/" -f $uriBuilder.Path.TrimEnd('/'), ($Segments.ForEach({
                $_.trim('/').trim()
            }) -join '/')
    
    Write-Verbose " URIPath: $($uriBuilder.Path)"
    
    if ($parameters) {
        # Loop through the parameters and use the HttpUtility to create a Query string
        [System.Collections.Specialized.NameValueCollection]$URIParams = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        foreach ($param in $Parameters.GetEnumerator()) {
            Write-Verbose " Adding URI parameter $($param.Key):$($param.Value)"
            $URIParams[$param.Key] = $param.Value
        }
        
        $uriBuilder.Query = $URIParams.ToString()
    }
    
    Write-Verbose " Completed building URIBuilder"
    # Return the entire UriBuilder object
    $uriBuilder
}



