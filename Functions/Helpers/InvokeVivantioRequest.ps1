
function InvokeVivantioRequest {
<#
    .SYNOPSIS
        Internal wrapper function for Invoke-RestMethod
    
    .DESCRIPTION
        A detailed description of the InvokeVivantioRequest function.
    
    .PARAMETER URI
        The URIBuilder used to target Invoke-RestMethod
    
    .PARAMETER Headers
        A hashtable of headers to include in the request. Authorization is automatically included
    
    .PARAMETER Body
        Request body data to include in the request (will be converted to JSON unless -BodyIsJSON is enabled)
    
    .PARAMETER BodyIsJSON
        Assert the provided object is already JSON string
    
    .PARAMETER Timeout
        How long to wait before timing out Invoke-RestMethod
    
    .PARAMETER Method
        HTTP Method [GET | PATCH | PUT | POST | DELETE | OPTIONS]
    
    .PARAMETER Raw
        Return the raw request data instead of custom object
    
    .EXAMPLE
        PS C:\> InvokeVivantioRequest -URI $MyURIBuilder
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,
        
        [Hashtable]$Headers = [hashtable]::new(),
        
        [object]$Body,
        
        [switch]$BodyIsJSON,
        
        [ValidateRange(1, 900)]
        [uint16]$Timeout = (Get-VivantioAPITimeout),
        
        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', 'OPTIONS', IgnoreCase = $true)]
        [string]$Method = 'GET',
        
        [switch]$Raw
    )
    
    $Headers['Authorization'] = GetHTTPBasicAuthorizationString -Credential (Get-VivantioAPICredential)
    
    $splat = @{
        'Method' = $Method
        'Uri'    = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers' = $Headers
        'TimeoutSec' = $Timeout
        'ErrorAction' = 'Stop'
        'Verbose' = $VerbosePreference
    }
    
    if ($PSBoundParameters.ContainsKey('Body')) {
        if (-not $BodyIsJSON) {
            # Provided body object is NOT JSON yet, convert it
            Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress -Depth 100)"
            $splat['Body'] = ($Body | ConvertTo-Json -Compress -Depth 100)
        } else {
            # Provided body is already JSON, add it as-is
            Write-Verbose "BODY: $Body"
            $splat['Body'] = $Body
        }
        
        $splat['ContentType'] = 'application/json'
    }
    
    if ($null -ne $script:VivantioPSConfig.Proxy) {
        Write-Verbose "Adding proxy '$($script:VivantioPSConfig.Proxy)' to request"
        $splat['Proxy'] = $script:VivantioPSConfig.Proxy
    }
    
    try {
        Write-Verbose "Calling URI: $($URI.Uri.AbsoluteUri)"
        $result = Invoke-RestMethod @splat
    } catch {
        throw $_
    }
    
    #region TODO: Handle errors a little more gracefully...
    
    <#
    try {
        Write-Verbose "Sending request..."
        $result = Invoke-RestMethod @splat
        Write-Verbose $result
    } catch {
        Write-Verbose "Caught exception"
        if ($_.Exception.psobject.properties.Name.contains('Response')) {
            Write-Verbose "Exception contains a response property"
            if ($Raw) {
                Write-Verbose "RAW provided...throwing raw exception"
                throw $_
            }

            Write-Verbose "Converting response to object"
            $myError = GetVivantioAPIErrorBody -Response $_.Exception.Response | ConvertFrom-Json
        } else {
            Write-Verbose "No response property found"
            $myError = $_
        }
    }

    Write-Verbose "MyError is $($myError.GetType().FullName)"

    if ($myError -is [Exception]) {
        throw $_
    } elseif ($myError -is [pscustomobject]) {
        throw $myError.detail
    }
    #>
    
    #endregion TODO: Handle errors a little more gracefully...
    
    # If the user wants the raw value from the API... otherwise return only the actual result
    if ($Raw) {
        Write-Verbose "Returning raw result by choice"
        return $result
    } else {
        if ($result.psobject.Properties.Name.Contains('Item')) {
            Write-Verbose "Found 'Item' property on data, returning 'Item' directly"
            return $result.Item
        } elseif ($result.psobject.Properties.Name.Contains('value')) {
            Write-Verbose "Found 'value' property on data, returning 'value' directly"
            return $result.value
        } elseif ($result.psobject.Properties.Name.Contains('Results')) {
            Write-Verbose "Found 'Results' property on data, returning 'Results' directly"
            return $result.Results
        } else {
            Write-Verbose "Did NOT find 'item' or 'value' property on data, returning raw result"
            return $result
        }
    }
}