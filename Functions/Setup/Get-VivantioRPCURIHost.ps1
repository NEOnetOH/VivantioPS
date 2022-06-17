function Get-VivantioAPIURIHost {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI Host"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Host) {
        throw "Vivantio API URI Host is not set! You may set it with Set-VivantioURIHost -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.URI.RPC.Host
}