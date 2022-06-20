

#region File BuildNewURI.ps1


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




#endregion

#region File BuildURIComponents.ps1


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

#region File Clear-VivantioAPICredential.ps1

function Clear-VivantioAPICredential {
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

#region File Clear-VivantioAPIProxy.ps1


function Clear-VivantioAPIProxy {
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
    param
    (
        [switch]$Force
    )
    
    if ($Force -or ($PSCmdlet.ShouldProcess('Vivantio API Proxy', 'Clear'))) {
        $script:VivantioPSConfig['Proxy'] = $null
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
    
    .PARAMETER Credential
        Credential object containing the API username and password
    
    .PARAMETER ODataURI
        URI for OData API
    
    .PARAMETER APIURI
        URI for basic API
    
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
        
        [string]$ODataURI,
        
        [string]$RPCURI,
        
        [ValidateRange(1, 65535)]
        [ValidateNotNullOrEmpty()]
        [uint16]$TimeoutSeconds = 30
    )
    
    if (-not $Credential) {
        try {
            $Credential = Get-VivantioAPICredential -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -Message "Enter credentials for Vivantio")) {
                throw "Credentials are necessary to connect to a Vivantio OData/API"
            }
        }
    }
    
    $null = Set-VivantioODataURI -URI $ODataURI
    $null = Set-VivantioRPCURI -URI $RPCURI
    $null = Set-VivantioAPICredential -Credential $Credential
    $null = Set-VivantioAPITimeout -TimeoutSeconds $TimeoutSeconds
    
    try {
        $null = VerifyRPCConnectivity -ErrorAction Stop
        $null = VerifyODataConnectivity -ErrorAction Stop
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

#region File Get-VivantioAPICredential.ps1

function Get-VivantioAPICredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()

    if (-not $script:VivantioPSConfig.Credential) {
        throw "Vivantio Credentials not set! You may set with Set-VivantioCredential"
    }

    $script:VivantioPSConfig.Credential
}

#endregion

#region File Get-VivantioAPITimeout.ps1


function Get-VivantioAPITimeout {
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

#region File Get-VivantioODataCaller.ps1


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

#endregion

#region File Get-VivantioODataURI.ps1


function Get-VivantioODataURI {
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param ()
    
    Write-Verbose "Getting Vivantio OData URI"
    if ($null -eq $script:VivantioPSConfig.URI.OData) {
        throw "Vivantio OData URI  is not set! You may set it with Set-VivantioODataURI -URI 'https://hostname.domain.tld/path'"
    }
    
    $script:VivantioPSConfig.URI.OData
}

#endregion

#region File Get-VivantioODataURIHost.ps1

function Get-VivantioODataURIHost {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI host"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Host) {
        throw "Vivantio OData URI host is not set! You may set it with Set-VivantioODataURIHost -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.URI.OData.Host
}

#endregion

#region File Get-VivantioODataURIPort.ps1

function Get-VivantioODataURIPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI port"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Port) {
        throw "Vivantio OData URI port is not set! You may set it with Set-VivantioODataURIPort -Port 443"
    }

    $script:VivantioPSConfig.URI.OData.Port
}

#endregion

#region File Get-VivantioODataURIScheme.ps1

function Get-VivantioODataURIScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI scheme"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Scheme) {
        throw "Vivantio OData URI scheme is not set! You may set it with Set-VivantioODataURIScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.URI.OData.Scheme
}

#endregion

#region File Get-VivantioRPCCaller.ps1


function Get-VivantioRPCCaller {
    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(ParameterSetName = 'Select',
                   Mandatory = $true)]
        [object]$Query,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [Parameter(ParameterSetName = 'SelectByQueue',
                   Mandatory = $true)]
        [object]$Queue,
        
        [Parameter(ParameterSetName = 'SelectPage',
                   Mandatory = $true)]
        [hashtable]$Page,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Caller'))
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Select' {
                [void]$Segments.Add($_)
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Body   = $Query
                    Raw    = $Raw
                    Method = 'POST'
                }
                
                if ($Query -is [System.String]) {
                    $paramInvokeVivantioRequest['BodyIsJSON'] = $true
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            'SelectById' {
                $paramInvokeVivantioRequest = @{
                    Raw = $Raw
                    Method = 'POST'
                }
                
                if (@($Id).Count -eq 1) {
                    Write-Verbose "Single ID"
                    [void]$Segments.AddRange(@('SelectById', $Id))
                } else {
                    [void]$Segments.Add('SelectList')
                    
                    Write-Verbose "$(@($Value).Count) IDs to select"
                    $paramInvokeVivantioRequest['Body'] = ,@($Id) | ConvertTo-Json -Compress
                    $paramInvokeVivantioRequest['BodyIsJSON'] = $true
                }
                
                $paramInvokeVivantioRequest['Uri'] = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            default {
                throw "'$_' NOT IMPLEMENTED"
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File Get-VivantioRPCClient.ps1


function Get-VivantioRPCClient {
    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(ParameterSetName = 'Select',
                   Mandatory = $true)]
        [object]$Query,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [Parameter(ParameterSetName = 'SelectByQueue',
                   Mandatory = $true)]
        [object]$Queue,
        
        [Parameter(ParameterSetName = 'SelectPage',
                   Mandatory = $true)]
        [hashtable]$Page,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Client'))
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Select' {
                [void]$Segments.Add($_)
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Body   = $Query
                    Raw    = $Raw
                    Method = 'POST'
                }
                
                if ($Query -is [System.String]) {
                    $paramInvokeVivantioRequest['BodyIsJSON'] = $true
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            'SelectById' {
                [void]$Segments.Add('SelectList')
                
                Write-Verbose "$(@($Value).Count) IDs to select"
                $IDListJSON = ,@($Id) | ConvertTo-Json -Compress
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body $IDListJSON -BodyIsJSON -Raw:$Raw -Method POST
                
                break
            }
            
            default {
                throw "'$_' NOT IMPLEMENTED"
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File Get-VivantioRPCCustomFormDefinition.ps1


function Get-VivantioRPCCustomFormDefinition {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(ParameterSetName = 'ByRecordTypeId',
                   Mandatory = $true)]
        [uint64]$RecordTypeId,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntityDefinitionSelectById', $Id))
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
                
                break
            }
            
            'ByRecordTypeId' {
                [void]$Segments.Add('CustomEntityDefinitionSelectByRecordTypeId')
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body @{'Id' = $RecordTypeId} -Method POST
                
                break
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File Get-VivantioRPCCustomFormFieldDefinition.ps1


function Get-VivantioRPCCustomFormFieldDefinition {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }
    
    process {
        [void]$Segments.AddRange(@('CustomEntityFieldDefinitionSelectById', $Id))
        
        $uri = BuildNewURI -Segments $Segments
        
        InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
        
        break
    }
    
    end {
        
    }
}

#endregion

#region File Get-VivantioRPCCustomFormInstance.ps1


function Get-VivantioRPCCustomFormInstance {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [uint64]$TypeId,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [uint64]$ParentId,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent',
                   Mandatory = $true)]
        [ValidateSet('Client', 'Location', 'Caller', 'Ticket', 'Asset', 'Article', IgnoreCase = $true)]
        [string]$SystemArea,
        
        [Parameter(ParameterSetName = 'ByTypeIdAndParent')]
        [switch]$Simplified,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntitySelectById', $Id))
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Method POST -Raw:$Raw
                
                break
            }
            
            'ByTypeIdAndParent' {
                if ($Simplified) {
                    [void]$Segments.Add('CustomEntitySimplifiedSelectByTypeIdAndParent')
                } else {
                    [void]$Segments.Add('CustomEntitySelectByTypeIdAndParent')
                }
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body @{
                    'TypeId'     = $TypeId
                    'ParentId'   = $ParentId
                    'SystemArea' = $SystemArea
                } -Method POST -Raw:$Raw
                
                break
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File Get-VivantioRPCURI.ps1


function Get-VivantioRPCURI {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Vivantio RPC URI "
    if ($null -eq $script:VivantioPSConfig.URI.RPC) {
        throw "Vivantio RPC URI is not set! You may set it with Set-VivantioRPCURI -URI 'https://hostname.domain.tld/path'"
    }
    
    $script:VivantioPSConfig.URI.RPC
}

#endregion

#region File Get-VivantioRPCURIHost.ps1

function Get-VivantioAPIURIHost {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI Host"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Host) {
        throw "Vivantio API URI Host is not set! You may set it with Set-VivantioURIHost -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.URI.RPC.Host
}

#endregion

#region File Get-VivantioRPCURIPort.ps1

function Get-VivantioAPIURIPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI port"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Port) {
        throw "Vivantio API URI port is not set! You may set it with Set-VivantioAPIURIPort -Port 443"
    }

    $script:VivantioPSConfig.URI.RPC.Port
}

#endregion

#region File Get-VivantioRPCURIScheme.ps1

function Get-VivantioAPIURIScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI scheme"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Scheme) {
        throw "Vivantio API URI scheme is not set! You may set it with Set-VivantioAPIURIScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.URI.RPC.Scheme
}

#endregion

#region File GetHTTPBasicAuthorizationString.ps1


function GetHTTPBasicAuthorizationString {
    [CmdletBinding(DefaultParameterSetName = 'String')]
    [OutputType([string], ParameterSetName = 'String')]
    [OutputType([hashtable], ParameterSetName = 'Hashtable')]
    param
    (
        [Parameter(Mandatory = $false)]
        [pscredential]$Credential,
        
        [Parameter(ParameterSetName = 'Hashtable')]
        [switch]$Hashtable
    )
    
    if (-not $PSBoundParameters.ContainsKey('Credential')) {
        if (-not ($Credential = Get-Credential -Message "Please provide credentials")) {
            throw "You must provide credentials"
        }
    }
    
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($("{0}:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password))
    $base64 = [System.Convert]::ToBase64String($bytes)
    
    switch ($PSCmdlet.ParameterSetName) {
        'Hashtable' {
            Write-Output( [hashtable]@{
                'Authorization' = "Basic $base64"
            })
        }
        
        default {
            Write-Output "Basic $base64"
        }
    }
}

#endregion

#region File GetVivantioConfigVariable.ps1

function GetVivantioConfigVariable {
    return $script:VivantioPSConfig
}

#endregion

#region File InvokeVivantioRequest.ps1


function InvokeVivantioRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,
        
        [Hashtable]$Headers = @{
        },
        
        [object]$Body,
        
        [switch]$BodyIsJSON,
        
        [ValidateRange(1, 65535)]
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

#endregion

#region File New-VivantioODataFilter.ps1


function New-VivantioODataFilter {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [ValidateSet('caller.contactroles.listserv', 'Id', 'Name', 'FirstName', 'LastName', 'Email', 'Phone', 'ClientId', 'LocationId', 'LocationName', 'ExternalKey', 'CreateDate', 'UpdateDate', 'RecordTypeId', 'Deleted', IgnoreCase = $true)]
        [string]$Property,
        
        [Parameter(Position = 1)]
        [ValidateSet('eq', 'ne', 'gt', 'lt', IgnoreCase = $true)]
        [string]$Operator = 'eq',
        
        [Parameter(Mandatory = $true,
                   Position = 2)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Value,
        
        [Parameter(Position = 3)]
        [ValidateSet('String', 'Integer', 'Boolean', IgnoreCase = $true)]
        [string]$ValueType = 'String'
    )
    
    if ($Operator -notin @('eq', 'ne')) {
        Write-Warning "Implementation of [$Operator] may be incomplete by Vivantio and return unexpected results!"
    }
    
    $baseString = "{0}='{1}' {2}" -f '$filter', $Property, $Operator
    
    if ($ValueType -ieq 'string') {
        "{0} '{1}'" -f $baseString, $Value
    } else {
        "{0} {1}" -f $baseString, $Value
    }
}

#endregion

#region File New-VivantioRPCQuery.ps1


function New-VivantioRPCQuery {
<#
    .SYNOPSIS
        A brief description of the New-VivantioAPIQuery function.
    
    .DESCRIPTION
        A detailed description of the New-VivantioAPIQuery function.
    
    .PARAMETER Mode
        [VivantioQueryMode]$Mode,
    
    .PARAMETER Items
        A description of the Items parameter.
    
    .PARAMETER JSON
        A description of the JSON parameter.
    
    .EXAMPLE
        		PS C:\> New-VivantioAPIQuery -Mode 'MatchAll' -Items $value2
    
    .OUTPUTS
        pscustomobject, string
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([pscustomobject], ParameterSetName = 'Default')]
    [OutputType([string], ParameterSetName = 'JSON')]
    param
    (
        [Parameter(ParameterSetName = 'Default',
                   Mandatory = $true,
                   Position = 0)]
        [ValidateSet('MatchAll', 'MatchAny', 'MatchNone', IgnoreCase = $true)]
        [string]$Mode = 'MatchAll',
        
        [Parameter(ParameterSetName = 'Default',
                   Mandatory = $true,
                   Position = 1)]
        [pscustomobject[]]$Items,
        
        [Parameter(ParameterSetName = 'JSON')]
        [string]$JSON
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        "Default" {
            [pscustomobject]@{
                "Query" = [pscustomobject]@{
                    'Mode'  = $Mode
                    'Items' = $Items
                }
            }
        }
    }
}

#endregion

#region File New-VivantioRPCQueryItem.ps1


function New-VivantioRPCQueryItem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [string]$FieldName,
        
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Equals', 'DoesNotEqual', 'GreaterThan', 'GreaterThanOrEqualTo', 'LessThan', 'LessThanOrEqualTo', 'Like', IgnoreCase = $true)]
        [string]$Operator,
        
        [Parameter(Mandatory = $true,
                   Position = 2)]
        [string]$Value
    )
    
    [pscustomobject]@{
        'FieldName' = $FieldName
        'Op'        = $Operator
        'Value'     = $Value
    }
}

#endregion

#region File Set-VivantioAPICredential.ps1

function Set-VivantioAPICredential {
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

#region File Set-VivantioAPIProxy.ps1


function Set-VivantioAPIProxy {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ProxyURI
    )
    
    if ([string]::IsNullOrWhiteSpace($ProxyURI)) {
        $script:VivantioPSConfig['Proxy'] = $null
    } else {
        $script:VivantioPSConfig['Proxy'] = $ProxyURI
    }
}

#endregion

#region File Set-VivantioAPITimeout.ps1


function Set-VivantioAPITimeout {
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

#region File Set-VivantioODataHostName.ps1

function Set-VivantioODataURIHost {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Host', 'Set')) {
        $script:VivantioPSConfig.URI.OData.Host = $Hostname.Trim()
        $script:VivantioPSConfig.URI.OData.Host
    }
}

#endregion

#region File Set-VivantioODataURI.ps1


function Set-VivantioODataURI {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$URI,
        
        [switch]$PassThru
    )
    
    $uriBuilder = [System.UriBuilder]::new($URI)
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI', 'Set')) {
        if ($uriBuilder.Scheme -ieq 'http') {
            Write-Warning "Connecting to OData via insecure HTTP is not recommended!"
        }
        
        $script:VivantioPSConfig.URI.OData = $uriBuilder
    }
    
    if ($PassThru) {
        $script:VivantioPSConfig.URI.OData
    }
}

#endregion

#region File Set-VivantioODataURIPort.ps1

function Set-VivantioODataURIPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Port', 'Set')) {
        $script:VivantioPSConfig.URI.OData.Port = $Port
        $script:VivantioPSConfig.URI.OData.Port
    }
}

#endregion

#region File Set-VivantioODataURIScheme.ps1

function Set-VivantioODataURIScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https'
    )

    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Scheme', 'Set')) {
        if ($Scheme -ieq 'http') {
            Write-Warning "Connecting to OData via insecure HTTP is not recommended!"
        }
    
        $script:VivantioPSConfig.URI.OData.Scheme = $Scheme.ToLower()
        $script:VivantioPSConfig.URI.OData.Scheme
    }
}

#endregion

#region File Set-VivantioRPCURI.ps1


function Set-VivantioRPCURI {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$URI,
        
        [switch]$PassThru
    )
    
    $uriBuilder = [System.UriBuilder]::new($URI)
    
    if ($PSCmdlet.ShouldProcess('Vivantio RPC URI', 'Set')) {
        if ($uriBuilder.Scheme -ieq 'http') {
            Write-Warning "Connecting to RPC API via insecure HTTP is not recommended!"
        }
        
        $script:VivantioPSConfig.URI.RPC = $uriBuilder
    }
    
    if ($PassThru) {
        $script:VivantioPSConfig.URI.RPC
    }
}

#endregion

#region File Set-VivantioRPCURIHost.ps1

function Set-VivantioAPIURIHost {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio API URI Host', 'Set')) {
        $script:VivantioPSConfig.URI.RPC.Host = $Hostname.Trim()
        $script:VivantioPSConfig.URI.RPC.Host
    }
}

#endregion

#region File Set-VivantioRPCURIPort.ps1

function Set-VivantioAPIURIPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio API URI Port', 'Set')) {
        $script:VivantioPSConfig.URI.RPC.Port = $Port
        $script:VivantioPSConfig.URI.RPC.Port
    }
}

#endregion

#region File Set-VivantioRPCURIScheme.ps1

function Set-VivantioAPIURIScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https'
    )

    if ($PSCmdlet.ShouldProcess('Vivantio API URI Scheme', 'Set')) {
        if ($Scheme -eq 'http') {
            Write-Warning "Connecting to API via insecure HTTP is not recommended!"
        }
    
        $script:VivantioPSConfig.URI.RPC.Scheme = $Scheme.ToLower()
        $script:VivantioPSConfig.URI.RPC.Scheme
    }
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
    if (($null -eq $script:VivantioPSConfig) -or $Overwrite) {
        Write-Verbose "Creating VivantioConfig hashtable"
        $script:VivantioPSConfig = @{
            'Connected' = $false
            'ConnectedTimestamp' = $null
            'URI'       = [pscustomobject]@{
                'RPC' = [System.UriBuilder]::new()
                'OData' = [System.UriBuilder]::new()
            }
        }
    } else {
        Write-Warning "Cannot overwrite VivantioConfig without -Overwrite parameter!"
    }
}

#endregion

#region File VerifyODataConnectivity.ps1


function VerifyODataConnectivity {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Verifying OData connectivity"
    
    $uriSegments = [System.Collections.ArrayList]::new(@('Callers'))
    
    $uriParameters = @{
        '$filter' = 'id eq 1'
    }
    
    $uri = BuildNewURI -APIType OData -Segments $uriSegments -Parameters $uriParameters -SkipConnectedCheck
    
    InvokeVivantioRequest -URI $uri -ErrorAction Stop
}

#endregion

#region File VerifyRPCConnectivity.ps1


function VerifyRPCConnectivity {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Verifying RPC API connectivity"
    
    $uriSegments = [System.Collections.ArrayList]::new(@('Caller', 'SelectById', '1'))

    $uri = BuildNewURI -APIType RPC -Segments $uriSegments -SkipConnectedCheck

    InvokeVivantioRequest -URI $uri -Method POST -ErrorAction Stop
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

Export-ModuleMember -Function '*-*'


## Exporting all functions for development ##
Export-ModuleMember -Function '*'
