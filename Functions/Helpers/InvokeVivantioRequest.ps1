
function InvokeVivantioRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,

        [Hashtable]$Headers = @{},

        [pscustomobject]$Body,

        [ValidateRange(1, 65535)]
        [uint16]$Timeout = (Get-VivantioTimeout),

        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', 'OPTIONS', IgnoreCase = $true)]
        [string]$Method = 'GET',

        [switch]$Raw
    )

    $Headers['Authorization'] = GetHTTPBasicAuthorizationString -Credential (Get-VivantioCredential)

    $splat = @{
        'Method'      = $Method
        'Uri'         = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers'     = $Headers
        'TimeoutSec'  = $Timeout
        'ErrorAction' = 'Stop'
        'Verbose'     = $VerbosePreference
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress)"
        $splat['Body'] = ($Body | ConvertTo-Json -Compress)
        $splat['ContentType'] = 'application/json'
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
        } else {
            Write-Verbose "Did NOT find 'item' or 'value' property on data, returning raw result"
            return $result
        }
    }
}