

#region File Add-VivantioRPCCustomFormInstance.ps1


function Add-VivantioRPCCustomFormInstance {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$ParentId,

        [Parameter(Mandatory = $true)]
        [uint64]$TypeId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Article', 'Asset', 'Caller', 'Client', 'Location', 'Ticket', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParentSystemArea,

        [Parameter(Mandatory = $true)]
        [pscustomobject[]]$FieldValues
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity', 'CustomEntityInsert'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = [pscustomobject]@{
            'ParentId'         = $ParentId
            'TypeId'           = $TypeId
            'ParentSystemArea' = $ParentSystemArea
            'FieldValues'      = [System.Collections.Arraylist]::new(@($FieldValues))
        } | ConvertTo-Json -Compress -Depth 100

        InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Method POST -Raw:$Raw
    }

    end {

    }
}







#endregion

#region File Add-VivantioRPCTicketNote.ps1


function Add-VivantioRPCTicketNote {
<#
    .SYNOPSIS
        Add a new note to a ticket

    .DESCRIPTION
        A detailed description of the Add-VivantioRPCTicketNote function.

    .PARAMETER TicketId
        A description of the TicketId parameter.

    .PARAMETER Notes
        A description of the Notes parameter.

    .PARAMETER MarkPrivate
        A description of the MarkPrivate parameter.

    .PARAMETER EmailTemplateId
        A description of the EmailTemplateId parameter.

    .EXAMPLE
        		PS C:\> Add-VivantioRPCTicketNote -TicketId $value1 -Notes 'Value2' -MarkPrivate

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64[]]$TicketId,

        [Parameter(Mandatory = $true)]
        [string]$Notes,

        [switch]$MarkPrivate,

        [ValidateNotNullOrEmpty()]
        [uint64]$EmailTemplateId
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'AddNote'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = @{
            AffectedTickets = $TicketId
            Notes           = $Notes
            MarkPrivate     = $MarkPrivate.ToBool()
        }

        if ($PSBoundParameters.ContainsKey('EmailTemplateId')) {
            $Body['EmailOptions'] = @{
                CustomerEmailTemplateId = $EmailTemplateId
                ReviewCustomerEmail     = $false
                NotifyOwner             = $true
            }
        }

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $Body
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}


#endregion

#region File BuildNewURI.ps1


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

    .PARAMETER ODataURI
        URI for OData API

    .PARAMETER RPCURI
        URI for RPC API

    .PARAMETER Credential
        Credential object containing the API username and password

    .PARAMETER TimeoutSeconds
        The number of seconds before the HTTP call times out. Defaults to 30 seconds. Limited to 900 seconds

    .EXAMPLE
        PS C:\> Connect-VivantioAPI -Hostname "Vivantio.domain.com"

        This will prompt for Credential, then proceed to attempt a connection to Vivantio

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ODataURI,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RPCURI,

        [Parameter(Mandatory = $false)]
        [pscredential]$Credential,

        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 900)]
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
    $script:VivantioPSConfig.ConnectedTimestamp = (Get-Date)
    Write-Verbose "Successfully connected!"

    Write-Verbose "Connection process completed"
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
            [hashtable]@{
                'Authorization' = "Basic $base64"
            }

            break
        }

        default {
            "Basic $base64"
        }
    }
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

#region File GetVivantioConfigVariable.ps1

function GetVivantioConfigVariable {
    return $script:VivantioPSConfig
}

#endregion

#region File Get-VivantioODataCaller.ps1


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




#endregion

#region File Get-VivantioODataClient.ps1


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
    } else {
        $Parameters['$skip'] = 0
    }

    $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters

    $paramWriteProgress = @{
        Id              = 1
        Activity        = "Obtaining Clients"
        Status          = "Request 1 of ?"
        PercentComplete = 1
    }

    Write-Progress @paramWriteProgress
    Write-Verbose "Obtaining initial page of data"
    $RawData = InvokeVivantioRequest -URI $uri -Raw -ErrorAction Stop
    Write-Verbose "Retrieved [$($RawData.value.count)] results"

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

#    $SkipAndValuesMatch = Test-VivantioODataResultsCountMatchNextURLSkipParameter -NextLink $Results.'@odata.nextLink' -Values $RawData.value -DetailedResults

#    if (-not $SkipAndValuesMatch.Matches) {
#        Write-Warning $("NextLink skip value [{0}] DOES NOT MATCH result count [{1}]" -f $SkipAndValuesMatch.SkipValue, $SkipAndValuesMatch.ValueCount)
#    }

    if ($All -and ($Clients.TotalClients -gt $RawData.value.Count)) {
        Write-Verbose "Looping to request all [$($Clients.TotalClients)] results"

        # Determine how many requests we need to make
        # Check the value count to request the next X amount
        $Remainder = 0
        $Clients.NumRequests = [math]::DivRem($Clients.TotalClients, $RawData.value.count, [ref]$Remainder)

        if ($Remainder -ne 0) {
            # The number of Clients is not divisible by $RawData.value.count without a remainder. Therefore we need at least
            # one more request to retrieve all Clients.
            $Clients.NumRequests++
        }

        Write-Verbose "Need to make $($Clients.NumRequests - 1) more requests"

        for ($RequestCounter = 1; $RequestCounter -lt $Clients.NumRequests; $RequestCounter++) {
            Write-Verbose "Request $($RequestCounter + 1) of $($Clients.NumRequests)"

            $PercentComplete = (($RequestCounter/$Clients.NumRequests) * 100)
            $paramWriteProgress = @{
                Id              = 1
                Activity        = "Obtaining Clients"
                Status          = "Request {0} of {1} ({2:N2}% Complete)" -f $RequestCounter, $Clients.NumRequests, $PercentComplete
                PercentComplete = $PercentComplete
            }

            Write-Progress @paramWriteProgress

            $Parameters['$skip'] = ($RequestCounter * $RawData.value.count)

            $uri = BuildNewURI -APIType OData -Segments $Segments -Parameters $Parameters

            $RawData = InvokeVivantioRequest -URI $uri -Raw
            Write-Verbose "Retrieved [$($RawData.value.count)] results"

            $Clients.'@odata.nextLink' = $RawData.'@odata.nextLink'
            $Clients.value.AddRange($RawData.value)
        }
    }

    Write-Progress @paramWriteProgress -Completed

    $Clients
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
        [ValidateNotNullOrEmpty()]
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
                    Raw    = $Raw
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
        [Parameter(ParameterSetName = 'Query',
                   Mandatory = $true)]
        [object]$Query,

        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Client'))
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Query' {
                [void]$Segments.Add('Select')

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
                Write-Verbose "$(@($Value).Count) IDs to select"

                if (@($Id).Count -eq 1) {
                    [void]$Segments.AddRange(@('SelectById', $Id))
                    $Body = @{} | ConvertTo-Json -Compress
                } else {
                    [void]$Segments.Add('SelectList')
                    $Body = @($Id) | ConvertTo-Json -Compress
                }

                $uri = BuildNewURI -Segments $Segments

                InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Raw:$Raw -Method POST

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
<#
    .SYNOPSIS
        Get the custom form definition

    .DESCRIPTION
        Provided the definition ID or RecordTypeId, get the system-wide custom form definition

    .PARAMETER Id
        Database ID of the form definition

    .PARAMETER RecordTypeId
        A description of the RecordTypeId parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        		PS C:\> Get-VivantioRPCCustomFormDefinition -RecordTypeId $value1

    .NOTES
        Additional information about the function.
#>

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
        $paramInvokeVivantioRequest = @{
            URI    = $null
            Method = 'POST'
            Raw    = $Raw
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntityDefinitionSelectById', $Id))

                break
            }

            'ByRecordTypeId' {
                [void]$Segments.Add('CustomEntityDefinitionSelectByRecordTypeId')

                $paramInvokeVivantioRequest['Body'] = @{
                    'Id' = $RecordTypeId
                }

                break
            }
        }

        $paramInvokeVivantioRequest.URI = BuildNewURI -Segments $Segments

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }

    end {

    }
}

#endregion

#region File Get-VivantioRPCCustomFormFieldDefinition.ps1


function Get-VivantioRPCCustomFormFieldDefinition {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
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

#region File Get-VivantioRPCEmailTemplate.ps1


function Get-VivantioRPCEmailTemplate {
<#
    .SYNOPSIS
        Get email template types

    .DESCRIPTION
        Get email template types

    .PARAMETER Type
        Get a particular email template by

    .PARAMETER RecordType
        Get the ticket type of the provided TicketID(s)

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Get-VivantioRPCEmailTemplate -TypeId 10

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-EmailTemplateSelectByType_type

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-EmailTemplateSelectByRecordTypeAndTemplateType_recordType_type
#>

    [CmdletBinding(DefaultParameterSetName = 'SelectByRecordTypeAndTemplateType')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('External', 'Internal', 'PasswordChange', 'Signature', 'EmailRejected', 'ScheduledReport', 'PasswordReset', 'Chat', 'SurveyResult', '0', '1', '2', '3', '4', '5', '6', '7', '8', IgnoreCase = $true)]
        [string]$Type,

        [Parameter(ParameterSetName = 'SelectByRecordTypeAndTemplateType')]
        [ValidateNotNullOrEmpty()]
        [uint64]$RecordType,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))

        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
        }

        $TypeStringToInt = @{
            'External'        = 0
            'Internal'        = 1
            'PasswordChange'  = 2
            'Signature'       = 3
            'EmailRejected'   = 4
            'ScheduledReport' = 5
            'PasswordReset'   = 6
            'Chat'            = 7
            'SurveyResult'    = 8
        }

        $Parameters = @{}

        if ([int]::TryParse($Type, [ref]$null)) {
            $Parameters['type'] = $Type
        } else {
            $Parameters['type'] = $TypeStringToInt[$Type]
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'SelectByRecordTypeAndTemplateType' {
                [void]$Segments.Add('EmailTemplateSelectByRecordTypeAndTemplateType')

                $Parameters['recordType'] = $RecordType

                break
            }

            default {
                [void]$Segments.Add('EmailTemplateSelectByType')

                break
            }
        }

        $paramInvokeVivantioRequest['uri'] = BuildNewURI -Segments $Segments -Parameters $Parameters

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}

#endregion

#region File Get-VivantioRPCTicket.ps1


function Get-VivantioRPCTicket {
<#
    .SYNOPSIS
        Get a Vivantio ticket

    .DESCRIPTION
        Get a ticket by ID or Query

    .PARAMETER Query
        A query generated by New-VivantioRPCQuery, containing items generated by New-VivantioRPCQueryItem

    .PARAMETER Id
        The database ID of the ticket

    .PARAMETER Raw
        Return the raw data from the request

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicket -Query $value1

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Select

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectById-id

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectList
#>

    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(ParameterSetName = 'Select',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]$Query,

        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket'))
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
                    Raw    = $Raw
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

#region File Get-VivantioRPCTicketType.ps1


function Get-VivantioRPCTicketType {
<#
    .SYNOPSIS
        Get ticket types

    .DESCRIPTION
        Get ticket types

    .PARAMETER NameSingular
        Get ticket type with this particular singular name

    .PARAMETER All
        Get all ticket types

    .PARAMETER TypeId
        Get a particular ticket type by ID

    .PARAMETER TicketId
        Get the ticket type of the provided TicketID(s)

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType -TypeId 100

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType -NameSingular 'Ticket'

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Select

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectById-id

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectList
#>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        [Parameter(ParameterSetName = 'NameSingular')]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string[]]$NameSingular,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64]$TypeId,

        [Parameter(ParameterSetName = 'SelectByTicketId')]
        [ValidateNotNullOrEmpty()]
        [uint64[]]$TicketId,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))

        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            { 'All' -or 'NameSingular' } {
                [void]$Segments.Add('TicketTypeSelectAll')

                break
            }

            'SelectById' {
                [void]$Segments.AddRange(@('TicketTypeSelectById', $TypeId))

                break
            }

            'SelectByTicketId' {
                [void]$Segments.Add('TicketTypeSelectByTicketIds')

                $paramInvokeVivantioRequest['Body'] = ( ,$TicketId | ConvertTo-Json -Compress)

                break
            }
        }

        $paramInvokeVivantioRequest['uri'] = BuildNewURI -Segments $Segments

        $Result = InvokeVivantioRequest @paramInvokeVivantioRequest

        if ($Raw) {
            Write-Warning "Raw parameter overrides filter for NameSingular"
            return $Result
        }

        if ($PsCmdlet.ParameterSetName -eq 'NameSingular') {
            $Result | Where-Object {
                $_.NameSingular -in $NameSingular
            }
        } else {
            $Result
        }
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

#region File Get-VivantioRPCUser.ps1


function Get-VivantioRPCUser {
<#
    .SYNOPSIS
        Get a Vivantio user/technian

    .DESCRIPTION
        Get Vivantio user(s) by Id, GroupId, or EmailAddress

    .PARAMETER All
        Get all users

    .PARAMETER Id
        One or more database IDs of user accounts

    .PARAMETER GroupId
        A database Id of a group

    .PARAMETER EmailAddress
        One or more email addresses to search for users

    .EXAMPLE
        PS C:\> Get-VivantioRPCUser -EmailAddress $value1

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectAll

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectByGroupId-id

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectById-id
#>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        [Parameter(ParameterSetName = 'All',
                   Mandatory = $true)]
        [switch]$All,

        [Parameter(ParameterSetName = 'Id',
                   Mandatory = $true)]
        [uint64[]]$Id,

        [Parameter(ParameterSetName = 'GroupId',
                   Mandatory = $true)]
        [uint64]$GroupId,

        [Parameter(ParameterSetName = 'EmailAddress',
                   Mandatory = $true)]
        [string[]]$EmailAddress
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            {
                'All' -or 'EmailAddress'
            } {
                [void]$Segments.Add('UserSelectAll')

                break
            }

            'Id' {
                if (@($Id).Count -gt 1) {
                    [void]$Segments.Add('UserSelectAll')
                } else {
                    [void]$Segments.AddRange(@('UserSelectById', $Id))
                }

                break
            }

            'GroupId' {
                [void]$Segments.AddRange(@('UserSelectByGroupId', $GroupId))

                break
            }
        }

        $uri = BuildNewURI -Segments $Segments

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Raw    = $Raw
            Method = 'POST'
        }

        $Results = InvokeVivantioRequest @paramInvokeVivantioRequest

        if ($PSCmdlet.ParameterSetName -eq 'EmailAddress') {
            Write-Verbose "Filtering results on email addresses [$EmailAddress]"

            $Results | Where-Object {
                $_.EmailAddress -in $EmailAddress
            }
        } elseif (@($Id).Count -gt 1) {
            Write-Verbose "Filtering results on IDs [$Id]"

            $Results | Where-Object {
                $_.Id -in $Id
            }
        } else {
            $Results
        }
    }
}

#endregion

#region File InvokeVivantioRequest.ps1


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
        [object]$Value,

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

#region File New-VivantioRPCCustomFormFieldValue.ps1


function New-VivantioRPCCustomFormFieldValue {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$FieldId,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    [pscustomobject]@{
        'FieldId' = $FieldId
        'Value' = $Value
    }
}






#endregion

#region File New-VivantioRPCQuery.ps1


function New-VivantioRPCQuery {
<#
    .SYNOPSIS
        Generates a hashtable of query items to feed to an RPC API query.

    .DESCRIPTION
        Generates a hashtable of query items to feed to an RPC API query.

    .PARAMETER Mode
        What type of matching the query will do [MatchAll | MatchAny | MatchNone]

    .PARAMETER Items
        A collection of QueryItems from New-VivantioRPCQueryItem

    .EXAMPLE
        PS C:\> New-VivantioAPIQuery
                -Mode 'MatchAll'
                -Items (New-VivantioRPCQuery -Mode MatchAll -Items (New-VivantioRPCQueryItem -FieldName 'email' -Operator Equals -Value 'user@domain.com'))

    .EXAMPLE
        PS C:\> New-VivantioAPIQuery 'MatchAll' $Items

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
        [pscustomobject[]]$Items
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
<#
    .SYNOPSIS
        Generate a hashtable query item for an RPC API query

    .DESCRIPTION
        Generate a hashtable query item for an RPC API query

    .PARAMETER FieldName
        The name of the field for filtering

    .PARAMETER Operator
        How the match will operate
        [Equals | DoesNotEqual | GreaterThan | GreaterThanOrEqualTo | LessThan | LessThanOrEqualTo | Like]

    .PARAMETER Value
        The value to match

    .EXAMPLE
        PS C:\> New-VivantioRPCQueryItem -FieldName 'Email' -Operator Equals -Value 'user@domain.com'

    .EXAMPLE
        PS C:\> New-VivantioRPCQueryItem 'Email' Equals 'user@domain.com'

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    [OutputType([hashtable])]
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

#region File New-VivantioRPCTicket.ps1

function New-VivantioRPCTicket {
<#
    .SYNOPSIS
        Create a new ticket via RPC

    .DESCRIPTION
        Create a new ticket via RPC

    .PARAMETER RecordTypeId
        The type of ticket (ticket types provided via Get-VivantioRPCTicketType)

    .PARAMETER ClientId
        Database ID of the client

    .PARAMETER CallerId
        Database ID of the caller

    .PARAMETER CategoryId
        Database ID of the category

    .PARAMETER Title
        Title/Subject/Summary

    .PARAMETER Description
        Plain text description for the ticket

    .PARAMETER DescriptionHTML
        HTML description for the ticket

    .PARAMETER GroupId
        Database ID of the group to assign the ticket

    .PARAMETER OwnerId
       Database ID of the user to assign the ticket

    .EXAMPLE
        PS C:\> New-VivantioRPCTicket -RecordTypeId $value1 -ClientId $value2 -CallerId $value3 -CategoryId $value4

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Insert
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$RecordTypeId,

        [Parameter(Mandatory = $true)]
        [uint64]$ClientId,

        [Parameter(Mandatory = $true)]
        [uint64]$CallerId,

        [Parameter(Mandatory = $true)]
        [uint64]$CategoryId,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [string]$Description,

        [string]$DescriptionHTML,

        [uint64]$GroupId,

        [uint64]$OwnerId
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Insert'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        # Parameter validation?
        # TicketType = Get-VivantioRPCTicketType -TypeId $RecordTypeId -ErrorAction Stop

        $Body = @{}

        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            $Body[$Parameter.Key] = $Parameter.Value
        }

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $Body
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}

#endregion

#region File New-VivantioRPCTicketUpdateRequest.ps1


function New-VivantioRPCTicketUpdateRequest {
<#
    .SYNOPSIS
        Create a ticket update request

    .DESCRIPTION
        Create a ticket update request to supply to Set-VivantioRPCTicket. If you provide an existing ticket,
        this will pre-populate the appropriate fields. If you specify other parameters, those will override
        the values provided in $TicketBody

    .PARAMETER TicketBody
        The ticket details returned by Get-VivantioRPCTicket

    .PARAMETER ClientId
        The internal ID of the Client

    .PARAMETER LocationId
        The internal ID of the Location

    .PARAMETER CallerId
        The internal ID of the caller

    .PARAMETER CallerName
        The name for the caller

    .PARAMETER CallerEmail
        The email for the caller

    .PARAMETER CallerPhone
        The phone number for the caller

    .PARAMETER OpenDate
        The date the ticket opened

    .PARAMETER TakenById
        The internal ID of the owning technician

    .PARAMETER ImpactId
        The internal ID of the impact level

    .PARAMETER Title
        The title of the ticket

    .PARAMETER Description
        The plain-text description

    .PARAMETER DescriptionHTML
       The HTML description

    .PARAMETER CCAddressList
        One or more email addresses to CC ticket updates

    .PARAMETER AffectedTickets
        The internal IDs of the tickets this operation applies to.

    .PARAMETER Effort
        The Effort, in minutes, to record in the ticket history

    .PARAMETER Notes
        The notes to add to the ticket history, in plain-text format. This property cannot be combined with the
        NotesHtml property.

    .PARAMETER NotesHTML
        The notes to add to the ticket history, in HTML format. This property cannot be combined with the
        Notes property.

    .PARAMETER MarkPrivate
        Flag indicating whether or not this operation should be considered Private. Emails cannot be sent for Private
        actions, and they cannot be viewed in the Self Service Portal.

    .EXAMPLE
        PS C:\> New-VivantioRPCTicketUpdateRequest

    .OUTPUTS
        Vivantio.TicketUpdateRequest

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/ResourceModel?modelName=TicketUpdateRequest
#>

    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Position = 0)]
        [psobject]$TicketBody,

        [uint64]$ClientId,

        [uint64]$LocationId,

        [uint64]$CallerId,

        [string]$CallerName,

        [string]$CallerEmail,

        [string]$CallerPhone,

        [datetime]$OpenDate,

        [uint64]$TakenById,

        [uint64]$ImpactId,

        [string]$Title,

        [string]$Description,

        [string]$DescriptionHTML,

        [string[]]$CCAddressList,

        [uint64[]]$AffectedTickets,

        [uint64]$Effort,

        [string]$Notes,

        [string]$NotesHTML,

        [switch]$MarkPrivate
    )

    begin {
        if ($PSBoundParameters.ContainsKey('Notes') -and $PSBoundParameters.ContainsKey('NotesHTML')) {
            Write-Error -ErrorRecord ([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Only ONE of parameters 'Notes' or 'NotesHTML' may be provided."), '1', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)) -ErrorAction Stop
        }

        $UR = [pscustomobject]@{
            "ClientId"        = $null # int
            "LocationId"      = $null # int
            "CallerId"        = $null # int
            "CallerName"      = $null # string
            "CallerEmail"     = $null # string
            "CallerPhone"     = $null # string
            "OpenDate"        = $null # date
            "TakenById"       = $null # int
            "ImpactId"        = $null # int
            "Title"           = $null # string
            "Description"     = $null # string
            "DescriptionHtml" = $null # string
            "CCAddressList"   = $null # string
            "AffectedTickets" = $null # Collection of int
            "Effort"          = $null # int
            "Notes"           = $null # string
            "NotesHtml"       = $null # string
            "MarkPrivate"     = $false # Bool
        }
    }

    process {
        if ($PSBoundParameters.ContainsKey('TicketBody')) {
            $UR.ClientId = $TicketBody.ClientId
            $UR.LocationId = $TicketBody.LocationId
            $UR.CallerId = $TicketBody.CallerId
            $UR.CallerName = $TicketBody.CallerName
            $UR.CallerEmail = $TicketBody.CallerEmail
            $UR.CallerPhone = $TicketBody.CallerPhone
            $UR.OpenDate = $TicketBody.OpenDate
            $UR.TakenById = $TicketBody.TakenById
            $UR.ImpactId = $TicketBody.ImpactId
            $UR.Title = $TicketBody.Title
            $UR.Description = $TicketBody.Description
            $UR.DescriptionHtml = $TicketBody.DescriptionHtml
            $UR.CCAddressList = @($TicketBody.CCAddressList -split ';').Trim()
            $UR.AffectedTickets = @($TicketBody.Id)
            $UR.Effort = $TicketBody.Effort
        }

        :ParameterLoop foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            switch ($Parameter.Key) {
                'TicketBody' {
                    continue ParameterLoop
                }

                'AffectedTickets' {
                    $UR.AffectedTickets = @($AffectedTickets)
                }

                default {
                    $UR.$_ = $Parameter.Value
                    break
                }
            }

        }

        $UR.psobject.typenames.insert(0, "Vivantio.TicketUpdateRequest")

        return $UR
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
                'RPC' = $null
                'OData' = $null
            }
            'Credential'         = $Null
            'Timeout'            = $null
            'Proxy' = $null
        }
    } else {
        Write-Warning "Cannot overwrite VivantioConfig without -Overwrite parameter!"
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
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(ParameterSetName = 'UserPass',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring]$Password
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Credentials', 'Set')) {
        switch ($PsCmdlet.ParameterSetName) {
            'CredsObject' {
                $script:VivantioPSConfig['Credential'] = $Credential
                break
            }

            'UserPass' {
                $script:VivantioPSConfig['Credential'] = [System.Management.Automation.PSCredential]::new($Username, $Password)
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
        [ValidateRange(1, 900)]
        [uint16]$TimeoutSeconds = 30
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Timeout', 'Set')) {
        $script:VivantioPSConfig.Timeout = $TimeoutSeconds
        $script:VivantioPSConfig.Timeout
    }
}

#endregion

#region File Set-VivantioODataHost.ps1

function Set-VivantioODataURIHost {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Host
    )

    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Host', 'Set')) {
        $script:VivantioPSConfig.URI.OData.Host = $Host.Trim()
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

#region File Set-VivantioRPCCustomForm.ps1


function Set-VivantioRPCCustomForm {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$Id,

        [Parameter(Mandatory = $true)]
        [psobject[]]$FieldValues
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity', 'CustomEntityUpdate'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = [pscustomobject]@{
            'Id'          = $Id
            'FieldValues' = [System.Collections.Arraylist]::new(@($FieldValues))
        } | ConvertTo-Json -Compress -Depth 100

        InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Method POST -Raw:$Raw
    }

    end {

    }
}

#endregion

#region File Set-VivantioRPCTicket.ps1


function Set-VivantioRPCTicket {
<#
    .SYNOPSIS
        Updates the core details of a ticket(s)

    .DESCRIPTION
        Update the core details of one or more tickets

    .PARAMETER TicketUpdateRequest
        A [Vivantio.TicketUpdateRequest] object returned from New-VivantioRPCTicketUpdateRequest

    .EXAMPLE
        PS C:\> Set-VivantioRPCTicket -TicketUpdateRequest $TicketUpdateRequest

    .EXAMPLE
        PS C:\> $Ticket = Get-VivantioRPCTicket -Id 122345
        PS C:\> Set-VivantioRPCTicket `
                  -TicketUpdateRequest (New-VivantioRPCTicketUpdateRequest -TicketBody $Ticket `
                                                                           -Title 'My New Ticket Title' `
                                                                           -ClientId 127 )

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Update
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]$TicketUpdateRequest
    )

    begin {
        if ($TicketUpdateRequest.psobject.TypeNames -notcontains 'Vivantio.TicketUpdateRequest') {
            Write-Error -ErrorRecord ([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Expected type 'Vivantio.TicketUpdateRequest' but got '$($TicketUpdateRequest.psobject.TypeNames[0])' for parameter TicketUpdateRequest"), '1', [System.Management.Automation.ErrorCategory]::InvalidType, $TicketUpdateRequest)) -ErrorAction Stop
        }

        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Update'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $TicketUpdateRequest.CCAddressList = $TicketUpdateRequest.CCAddressList -join '; '

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $TicketUpdateRequest
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}

#endregion

#region File Set-VivantioRPCTicketStatus.ps1


function Set-VivantioRPCTicketStatus {
<#
    .SYNOPSIS
        Update a ticket status

    .DESCRIPTION
        Update/set a ticket's status

    .PARAMETER TicketId
        Database ID of the target ticket

    .PARAMETER StatusId
        Database ID of the target status

    .PARAMETER MarkPrivate
        Set the change to private

    .EXAMPLE
        PS C:\> Set-VivantioRPCTicketStatus -TicketId 12345 -StatusId 152

    .NOTES
        This does not currently support sending any emails

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-ChangeStatus
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$TicketId,

        [Parameter(Mandatory = $true)]
        [uint64]$StatusId,

        [switch]$MarkPrivate,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'ChangeStatus'))
    }

    process {
        $Body = [pscustomobject]@{
            AffectedTickets = ,$TicketId
            StatusId        = $StatusId
            MarkPrivate     = $MarkPrivate.ToString().ToLower()
        }

        $uri = BuildNewURI -Segments $Segments

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $Body
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
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

#region File Test-VivantioODataResultsCountMatchNextURLSkipParameter.ps1


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

#Export-ModuleMember -Function '*-*'


