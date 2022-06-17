function Get-VivantioODataURIHost {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI host"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Host) {
        throw "Vivantio OData URI host is not set! You may set it with Set-VivantioODataURIHost -Hostname 'hostname.domain.tld'"
    }

    $script:VivantioPSConfig.URI.OData.Host
}