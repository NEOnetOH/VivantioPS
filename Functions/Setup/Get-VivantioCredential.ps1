function Get-VivantioCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()

    if (-not $script:VivantioPSConfig.Credential) {
        throw "Vivantio Credentials not set! You may set with Set-VivantioCredential"
    }

    $script:VivantioPSConfig.Credential
}