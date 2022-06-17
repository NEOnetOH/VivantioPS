
function Get-VivantioAPIURI {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Vivantio API URI "
    if ($null -eq $script:VivantioPSConfig.URI.RPC) {
        throw "Vivantio API URI is not set! You may set it with Set-VivantioURI -URI 'https://hostname.domain.tld/path'"
    }
    
    $script:VivantioPSConfig.URI.RPC
}