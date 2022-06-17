function Get-VivantioODataURIPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI port"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Port) {
        throw "Vivantio OData URI port is not set! You may set it with Set-VivantioODataURIPort -Port 443"
    }

    $script:VivantioPSConfig.URI.OData.Port
}