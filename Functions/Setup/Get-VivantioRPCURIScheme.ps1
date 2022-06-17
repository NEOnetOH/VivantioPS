function Get-VivantioAPIURIScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API URI scheme"
    if ($null -eq $script:VivantioPSConfig.URI.RPC.Scheme) {
        throw "Vivantio API URI scheme is not set! You may set it with Set-VivantioAPIURIScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.URI.RPC.Scheme
}