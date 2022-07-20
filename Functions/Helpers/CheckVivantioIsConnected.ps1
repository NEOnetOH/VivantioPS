
function CheckVivantioIsConnected {
    [CmdletBinding()]
    param ()

    Write-Verbose "Checking connection status"
    if (-not $script:VivantioPSConfig.Connected) {
        throw "Not connected to a Vivantio API! Please run 'Connect-VivantioAPI'"
    }
}