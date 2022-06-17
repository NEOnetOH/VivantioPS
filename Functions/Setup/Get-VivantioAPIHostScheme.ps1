function Get-VivantioAPIHostScheme {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio API host scheme"
    if ($null -eq $script:VivantioPSConfig.URI.API.Scheme) {
        throw "Vivantio API host sceme is not set! You may set it with Set-VivantioAPIHostScheme -Scheme 'https'"
    }

    $script:VivantioPSConfig.URI.API.Scheme
}