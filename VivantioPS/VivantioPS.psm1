

#region File BuildNewURI.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildNewURI.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Vivantio
    
    .DESCRIPTION
        Internal function used to build a URIBuilder object.
    
    .PARAMETER Segments
        Array of strings for each segment in the URL path
    
    .PARAMETER Parameters
        Hashtable of query parameters to include
    
    .PARAMETER APIType
        A description of the APIType parameter.
    
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
        [Parameter(Mandatory = $false)]
        [string[]]$Segments,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters,
        
        [ValidateSet('API', 'OData', IgnoreCase = $true)]
        [string]$APIType = 'API',
        
        [switch]$SkipConnectedCheck
    )
    
    Write-Verbose "Building URI"
    
    if (-not $SkipConnectedCheck) {
        # There is no point in continuing if we have not successfully connected to an API
        $null = CheckVivantioIsConnected
    }
    
    # Begin a URI builder with HTTP/HTTPS and the provided hostname
    $uriBuilder = if ($APIType -eq 'API') {
        [System.UriBuilder]::new($script:VivantioConfig.HostScheme, $script:VivantioConfig.Hostname, $script:VivantioConfig.HostPort)
    } else {
        [System.UriBuilder]::new($script:VivantioConfig.HostSchemeOData, $script:VivantioConfig.HostnameOData, $script:VivantioConfig.HostPortOData)
    }
    
    # Generate the path by trimming excess slashes and whitespace from the $segments[] and joining together
    $uriBuilder.Path = "{0}/{1}/" -f $APIType.ToLower(), ($Segments.ForEach({
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

#endregion

#region File BuildURIComponents.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildURIComponents.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function BuildURIComponents {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$URISegments,

        [Parameter(Mandatory = $true)]
        [object]$ParametersDictionary,

        [string[]]$SkipParameterByName
    )

    Write-Verbose "Building URI components"

    $URIParameters = @{}

    foreach ($CmdletParameterName in $ParametersDictionary.Keys) {
        if ($CmdletParameterName -in $script:CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping common parameter $CmdletParameterName"
            continue
        }

        if ($CmdletParameterName -in $SkipParameterByName) {
            Write-Debug "Skipping parameter $CmdletParameterName by SkipParameterByName"
            continue
        }

        switch ($CmdletParameterName) {
            "id" {
                # Check if there is one or more values for Id and build a URI or query as appropriate
                if (@($ParametersDictionary[$CmdletParameterName]).Count -gt 1) {
                    Write-Verbose " Joining IDs for parameter"
                    $URIParameters['id__in'] = $ParametersDictionary[$CmdletParameterName] -join ','
                } else {
                    Write-Verbose " Adding ID to segments"
                    [void]$uriSegments.Add($ParametersDictionary[$CmdletParameterName])
                }

                break
            }

            'Query' {
                Write-Verbose " Adding query parameter"
                $URIParameters['q'] = $ParametersDictionary[$CmdletParameterName]
                break
            }

            'CustomFields' {
                Write-Verbose " Adding custom field query parameters"
                foreach ($field in $ParametersDictionary[$CmdletParameterName].GetEnumerator()) {
                    Write-Verbose "  Adding parameter 'cf_$($field.Key) = $($field.Value)"
                    $URIParameters["cf_$($field.Key.ToLower())"] = $field.Value
                }

                break
            }

            default {
                Write-Verbose " Adding $($CmdletParameterName.ToLower()) parameter"
                $URIParameters[$CmdletParameterName.ToLower()] = $ParametersDictionary[$CmdletParameterName]
                break
            }
        }
    }

    return @{
        'Segments' = [System.Collections.ArrayList]$URISegments
        'Parameters' = $URIParameters
    }
}

#endregion

#region File CheckVivantioIsConnected.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckVivantioIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckVivantioIsConnected {
    [CmdletBinding()]
    param ()

    Write-Verbose "Checking connection status"
    if (-not $script:VivantioPSConfig.Connected) {
        throw "Not connected to a Vivantio API! Please run 'Connect-VivantioAPI'"
    }
}

#endregion

#region File Clear-VivantioCredential.ps1

function Clear-VivantioCredential {
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
    param
    (
        [switch]$Force
    )
    
    if ($Force -or ($PSCmdlet.ShouldProcess('Vivantio Credentials', 'Clear'))) {
        $script:VivantioPSConfig['Credential'] = $null
    }
}

#endregion

#region File Connect-VivantioAPI.ps1

function Connect-VivantioAPI {
<#
    .SYNOPSIS
        Connects to the Vivantio API and ensures Credential work properly

    .DESCRIPTION
        Connects to the Vivantio API and ensures Credential work properly

    .PARAMETER Hostname
        The hostname for the resource such as Vivantio.domain.com

    .PARAMETER Credential
        Credential object containing the API username and password

    .PARAMETER Scheme
        Scheme for the URI such as HTTP or HTTPS. Defaults is HTTPS

    .PARAMETER Port
        Port for the resource. Value between 1-65535. Default is 443

    .PARAMETER URI
        The full URI for the resource such as "https://Vivantio.domain.com:8443". This overrides the individual
        Scheme, Hostname, and Port parameters.

    .PARAMETER SkipCertificateCheck
        Ignore invalid certificates.

    .PARAMETER TimeoutSeconds
        The number of seconds before the HTTP call times out. Defaults to 30 seconds

    .EXAMPLE
        PS C:\> Connect-VivantioAPI -Hostname "Vivantio.domain.com"

        This will prompt for Credential, then proceed to attempt a connection to Vivantio

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [pscredential]$Credential,

        [Parameter()]
        [string]$ODataURI = 'https://neonet.vivantio.com/odata/',
        
        [Parameter()]
        [string]$APIURI = 'https://webservices-na01.vivantio.com/api/',
        
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if (-not $Credential) {
        try {
            $Credential = Get-VivantioCredential -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -Message "Enter credentials for Vivantio")) {
                throw "Credentials are necessary to connect to a Vivantio API."
            }
        }
    }
#
#    $invokeParams = @{ SkipCertificateCheck = $SkipCertificateCheck; }
#
#    if ("Desktop" -eq $PSVersionTable.PsEdition) {
#        #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
#        $invokeParams.remove("SkipCertificateCheck")
#    }
#
#    #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust
#    if ("Desktop" -eq $PSVersionTable.PsEdition) {
#        #Add System.web (Need for ParseQueryString)
#        Add-Type -AssemblyName System.Web
#        #Enable TLS 1.1 and 1.2
#        Set-VivantioCipherSSL
#        if ($SkipCertificateCheck) {
#            #Disable SSL chain trust...
#            Set-VivantiountrustedSSL
#        }
#    }
    
    # Set OData variables
    $uriBuilder = [System.UriBuilder]::new($ODataURI)
    if ([string]::IsNullOrWhiteSpace($uriBuilder.Host) -or [string]::IsNullOrWhiteSpace($uriBuilder.Path)) {
        throw "OData appears to be invalid. Must be in format [scheme://host.name/odata], or [scheme://host.name:port/odata]"
    }
    
    $null = Set-VivantioHostName -Hostname $uriBuilder.Host -OData
    $null = Set-VivantioHostScheme -Scheme $uriBuilder.Scheme -OData
    $null = Set-VivantioHostPort -Port $uriBuilder.Port -OData
    
    # Set standard API variables
    $uriBuilder = [System.UriBuilder]::new($APIURI)
    if ([string]::IsNullOrWhiteSpace($uriBuilder.Host) -or [string]::IsNullOrWhiteSpace($uriBuilder.Path)) {
        throw "API URI appears to be invalid. Must be in format [scheme://host.name/api], or [scheme://host.name:port/api]"
    }
    
    $null = Set-VivantioHostName -Hostname $uriBuilder.Host
    $null = Set-VivantioHostScheme -Scheme $uriBuilder.Scheme
    $null = Set-VivantioHostPort -Port $uriBuilder.Port
    
    
    
    $null = Set-VivantioCredential -Credential $Credential
#    $null = Set-VivantioInvokeParams -invokeParams $invokeParams
    $null = Set-VivantioTimeout -TimeoutSeconds $TimeoutSeconds

    try {
        Write-Verbose "Verifying API connectivity..."
        #$null = VerifyAPIConnectivity
    } catch {
        Write-Verbose "Failed to connect. Generating error"
        Write-Verbose $_.Exception.Message
        if (($_.Exception.Response) -and ($_.Exception.Response.StatusCode -eq 403)) {
            throw "Invalid token"
        } else {
            throw $_
        }
    }
        
    $script:VivantioPSConfig.Connected = $true
    Write-Verbose "Successfully connected!"

    Write-Verbose "Connection process completed"
}

#endregion

#region File Get-VivantioAPIDefinition.ps1

<#
    .NOTES
    ===========================================================================
     Created with:     SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
     Created on:       4/28/2020 11:57
     Created by:       Claussen
     Organization:     NEOnet
     Filename:         Get-VivantioAPIDefinition.ps1
    ===========================================================================
    .DESCRIPTION
        A description of the file.
#>



function Get-VivantioAPIDefinition {
    [CmdletBinding()]
    param ()

    #$URI = "https://Vivantio.neonet.org/api/docs/?format=openapi"

    $Segments = [System.Collections.ArrayList]::new(@('docs'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{'format' = 'openapi' }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeVivantioRequest -URI $URI
}

#endregion

#region File Get-VivantioCallerById.ps1

function Get-VivantioCallerById {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [uint32[]]$Id,

        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('Callers'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
    
    break
}

#endregion

#region File Get-VivantioCredential.ps1

function Get-VivantioCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()

    if (-not $script:VivantioPSConfig.Credential) {
        throw "Vivantio Credentials not set! You may set with Set-VivantioCredential"
    }

    $script:VivantioPSConfig.Credential
}

#endregion

#region File Get-VivantioHostname.ps1

function Get-VivantioHostname {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio hostname"
    if ($null -eq $script:VivantioPSConfig.Hostname) {
        throw "Vivantio Hostname is not set! You may set it with Set-VivantioHostname -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.Hostname
}

#endregion

#region File Get-VivantioHostPort.ps1

function Get-VivantioHostPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio host port"
    if ($null -eq $script:VivantioPSConfig.HostPort) {
        throw "Vivantio host port is not set! You may set it with Set-VivantioHostPort -Port 'https'"
    }

    $script:VivantioPSConfig.HostPort
}

#endregion

#region File Get-VivantioHostScheme.ps1

function Get-VivantioHostScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio host scheme"
    if ($null -eq $script:VivantioPSConfig.Hostscheme) {
        throw "Vivantio host sceme is not set! You may set it with Set-VivantioHostScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.HostScheme
}

#endregion

#region File Get-VivantioInvokeParams.ps1

function Get-VivantioInvokeParams {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio InvokeParams"
    if ($null -eq $script:VivantioPSConfig.InvokeParams) {
        throw "Vivantio Invoke Params is not set! You may set it with Set-VivantioInvokeParams -InvokeParams ..."
    }

    $script:VivantioPSConfig.InvokeParams
}

#endregion

#region File Get-VivantioTimeout.ps1


function Get-VivantioTimeout {
    [CmdletBinding()]
    [OutputType([uint16])]
    param ()

    Write-Verbose "Getting Vivantio Timeout"
    if ($null -eq $script:VivantioPSConfig.Timeout) {
        throw "Vivantio Timeout is not set! You may set it with Set-VivantioTimeout -TimeoutSeconds [uint16]"
    }

    $script:VivantioPSConfig.Timeout
}

#endregion

#region File Get-VivantioVersion.ps1


function Get-VivantioVersion {
    [CmdletBinding()]
    param ()

    $Segments = [System.Collections.ArrayList]::new(@('status'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{
        'format' = 'json'
    }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeVivantioRequest -URI $URI
}

#endregion

#region File GetVivantioAPIErrorBody.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	GetVivantioAPIErrorBody.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function GetVivantioAPIErrorBody {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Net.HttpWebResponse]$Response
    )

    # This takes the $Response stream and turns it into a useable object... generally a string.
    # If the body is JSON, you should be able to use ConvertFrom-Json

    $reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $reader.ReadToEnd()
}

#endregion

#region File GetVivantioConfigVariable.ps1

function GetVivantioConfigVariable {
    return $script:VivantioPSConfig
}

#endregion

#region File InvokeVivantioRequest.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:24
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	InvokeVivantioRequest.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function InvokeVivantioRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,

        [Hashtable]$Headers = @{
        },

        [pscustomobject]$Body = $null,

        [ValidateRange(1, 65535)]
        [uint16]$Timeout = (Get-VivantioTimeout),

        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', 'OPTIONS', IgnoreCase = $true)]
        [string]$Method = 'GET',

        [switch]$Raw
    )

    $creds = Get-VivantioCredential

    $Headers.Authorization = "Token {0}" -f $creds.GetNetworkCredential().Password

    $splat = @{
        'Method'      = $Method
        'Uri'         = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers'     = $Headers
        'TimeoutSec'  = $Timeout
        'ContentType' = 'application/json'
        'ErrorAction' = 'Stop'
        'Verbose'     = $VerbosePreference
    }

    $splat += Get-VivantioInvokeParams

    if ($Body) {
        Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress)"
        $null = $splat.Add('Body', ($Body | ConvertTo-Json -Compress))
    }

    $result = Invoke-RestMethod @splat

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
        if ($result.psobject.Properties.Name.Contains('results')) {
            Write-Verbose "Found Results property on data, returning results directly"
            return $result.Results
        } else {
            Write-Verbose "Did NOT find results property on data, returning raw result"
            return $result
        }
    }
}

#endregion

#region File Set-VivantioCipherSSL.ps1

Function Set-VivantioCipherSSL {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessforStateChangingFunctions", "")]
    Param(  )
    # Hack for allowing TLS 1.1 and TLS 1.2 (by default it is only SSL3 and TLS (1.0))
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

}

#endregion

#region File Set-VivantioCredential.ps1

function Set-VivantioCredential {
    [CmdletBinding(DefaultParameterSetName = 'CredsObject',
        ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([pscredential])]
    param
    (
        [Parameter(ParameterSetName = 'CredsObject',
            Mandatory = $true)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'UserPass',
            Mandatory = $true)]
        [securestring]$Token
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Credentials', 'Set')) {
        switch ($PsCmdlet.ParameterSetName) {
            'CredsObject' {
                $script:VivantioPSConfig['Credential'] = $Credential
                break
            }

            'UserPass' {
                $script:VivantioPSConfig['Credential'] = [System.Management.Automation.PSCredential]::new('notapplicable', $Token)
                break
            }
        }

        $script:VivantioPSConfig['Credential']
    }
}

#endregion

#region File Set-VivantioHostName.ps1

function Set-VivantioHostName {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        
        [switch]$OData
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio Hostname', 'Set')) {
        if ($OData) {
            $script:VivantioPSConfig['HostnameOData'] = $Hostname.Trim()
            $script:VivantioPSConfig.HostnameOData
        } else {
            $script:VivantioPSConfig['Hostname'] = $Hostname.Trim()
            $script:VivantioPSConfig.Hostname
        }
    }
}

#endregion

#region File Set-VivantioHostPort.ps1

function Set-VivantioHostPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port,
        
        [switch]$OData
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio Port', 'Set')) {
        if ($OData) {
            $script:VivantioPSConfig['HostPortOData'] = $Port
            $script:VivantioPSConfig.HostPortOData
        } else {
            $script:VivantioPSConfig['HostPort'] = $Port
            $script:VivantioPSConfig.HostPort
        }
    }
}

#endregion

#region File Set-VivantioHostScheme.ps1

function Set-VivantioHostScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https',
        
        [switch]$OData
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Host Scheme', 'Set')) {
        if ($Scheme -eq 'http') {
            Write-Warning "Connecting via non-secure HTTP is not-recommended"
        }
        
        if ($Odata) {
            $script:VivantioPSConfig['HostSchemeOData'] = $Scheme
            $script:VivantioPSConfig.HostSchemeOData
        } else {
            $script:VivantioPSConfig['HostScheme'] = $Scheme
            $script:VivantioPSConfig.HostScheme
        }
        
    }
}

#endregion

#region File Set-VivantioInvokeParams.ps1

function Set-VivantioInvokeParams {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [array]$InvokeParams
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Invoke Params', 'Set')) {
        $script:VivantioPSConfig.InvokeParams = $InvokeParams
        $script:VivantioPSConfig.InvokeParams
    }
}

#endregion

#region File Set-VivantioTimeout.ps1


function Set-VivantioTimeout {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Timeout', 'Set')) {
        $script:VivantioPSConfig.Timeout = $TimeoutSeconds
        $script:VivantioPSConfig.Timeout
    }
}

#endregion

#region File Set-VivantioUnstrustedSSL.ps1

Function Set-VivantioUntrustedSSL {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessforStateChangingFunctions", "")]
    Param(  )
    # Hack for allowing untrusted SSL certs with https connections
    Add-Type -TypeDefinition @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

    [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy

}

#endregion

#region File SetupVivantioConfigVariable.ps1

function SetupVivantioConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )

    Write-Verbose "Checking for VivantioConfig hashtable"
    if ((-not ($script:VivantioPSConfig)) -or $Overwrite) {
        Write-Verbose "Creating VivantioConfig hashtable"
        $script:VivantioPSConfig = @{
            'Connected'     = $false
        }
    }

    Write-Verbose "VivantioConfig hashtable already exists"
}

#endregion

#region File VerifyAPIConnectivity.ps1

function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()

    $uriSegments = [System.Collections.ArrayList]::new(@('extras'))

    $uri = BuildNewURI -Segments $uriSegments -Parameters @{'format' = 'json' } -SkipConnectedCheck

    InvokeVivantioRequest -URI $uri
}

#endregion

<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.206
	 Created on:   	2022-06-16 2:03 PM
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	VivantioPS.psm1
	-------------------------------------------------------------------------
	 Module Name: VivantioPS
	===========================================================================
#>


# Build a list of common parameters so we can omit them to build URI parameters
$script:CommonParameterNames = New-Object System.Collections.ArrayList
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::CommonParameters))
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
[void]$script:CommonParameterNames.Add('Raw')

SetupVivantioConfigVariable

Export-ModuleMember -Function *


