
function Get-VivantioRPCURI {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Vivantio RPC URI "
    if ($null -eq $script:VivantioPSConfig.URI.RPC) {
        throw "Vivantio RPC URI is not set! You may set it with Set-VivantioRPCURI -URI 'https://hostname.domain.tld/path'"
    }
    
    $script:VivantioPSConfig.URI.RPC
}