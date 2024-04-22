
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