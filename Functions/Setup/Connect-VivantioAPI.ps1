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
    
    $script:VivantioPSConfig.URI.OData = $uriBuilder
    
#    $null = Set-VivantioHostName -Hostname $uriBuilder.Host -OData
#    $null = Set-VivantioHostScheme -Scheme $uriBuilder.Scheme -OData
#    $null = Set-VivantioHostPort -Port $uriBuilder.Port -OData
    
    # Set standard API variables
    $uriBuilder = [System.UriBuilder]::new($APIURI)
    if ([string]::IsNullOrWhiteSpace($uriBuilder.Host) -or [string]::IsNullOrWhiteSpace($uriBuilder.Path)) {
        throw "API URI appears to be invalid. Must be in format [scheme://host.name/api], or [scheme://host.name:port/api]"
    }
    
    $script:VivantioPSConfig.URI.API = $uriBuilder
    
#    $null = Set-VivantioHostName -Hostname $uriBuilder.Host
#    $null = Set-VivantioHostScheme -Scheme $uriBuilder.Scheme
#    $null = Set-VivantioHostPort -Port $uriBuilder.Port
#    
    
    
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