function Get-VivantioAPIHostname {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API hostname"
    if ($null -eq $script:VivantioPSConfig.URI.API.Host) {
        throw "Vivantio API Hostname is not set! You may set it with Set-VivantioHostname -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.URI.API.Host
}