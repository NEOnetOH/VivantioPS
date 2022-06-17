function Get-VivantioODataURIScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio OData URI scheme"
    if ($null -eq $script:VivantioPSConfig.URI.OData.Scheme) {
        throw "Vivantio OData URI scheme is not set! You may set it with Set-VivantioODataURIScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.URI.OData.Scheme
}