function Get-VivantioAPIURIPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI port"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Port) {
        throw "Vivantio API URI port is not set! You may set it with Set-VivantioAPIURIPort -Port 443"
    }

    $script:VivantioPSConfig.URI.RPC.Port
}