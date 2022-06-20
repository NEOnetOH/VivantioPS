
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
            $Credential = Get-VivantioCredential -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -Message "Enter credentials for Vivantio")) {
                throw "Credentials are necessary to connect to a Vivantio OData/API"
            }
        }
    }
    
    $null = Set-VivantioODataURI -URI $ODataURI
    $null = Set-VivantioRPCURI -URI $RPCURI
    $null = Set-VivantioCredential -Credential $Credential
    $null = Set-VivantioTimeout -TimeoutSeconds $TimeoutSeconds
    
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

