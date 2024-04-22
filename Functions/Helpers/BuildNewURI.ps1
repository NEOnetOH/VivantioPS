
function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Vivantio

    .DESCRIPTION
        Internal function used to build a URIBuilder object.

    .PARAMETER APIType
        OData or RPC.

    .PARAMETER Segments
        Array of strings for each segment in the URL path

    .PARAMETER Parameters
        Hashtable of query parameters to include

    .PARAMETER SkipConnectedCheck
        Don't check if we are already connected to the API.

    .EXAMPLE
        PS C:\> BuildNewURI

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param
    (
        [ValidateSet('RPC', 'OData', IgnoreCase = $true)]
        [string]$APIType = 'RPC',

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
    $uriBuilder = if ($APIType -eq 'RPC') {
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



