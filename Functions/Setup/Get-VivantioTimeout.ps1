
function Get-VivantioTimeout {
    [CmdletBinding()]
    [OutputType([uint16])]
    param ()

    Write-Verbose "Getting Vivantio Timeout"
    if ($null -eq $script:VivantioPSConfig.Timeout) {
        throw "Vivantio Timeout is not set! You may set it with Set-VivantioTimeout -TimeoutSeconds [uint16]"
    }

    $script:VivantioPSConfig.Timeout
}