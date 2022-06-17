function Get-VivantioAPIHostPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API host port"
    if ($null -eq $script:VivantioPSConfig.URI.API.Port) {
        throw "Vivantio API host port is not set! You may set it with Set-VivantioAPIHostPort -Port 443"
    }

    $script:VivantioPSConfig.URI.API.Port
}