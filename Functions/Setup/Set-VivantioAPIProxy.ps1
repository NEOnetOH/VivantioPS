
function Set-VivantioAPIProxy {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ProxyURI
    )
    
    if ([string]::IsNullOrWhiteSpace($ProxyURI)) {
        $script:VivantioPSConfig['Proxy'] = $null
    } else {
        $script:VivantioPSConfig['Proxy'] = $ProxyURI
    }
}
