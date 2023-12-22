function Set-VivantioAPIURIScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https'
    )

    if ($PSCmdlet.ShouldProcess('Vivantio API URI Scheme', 'Set')) {
        if ($Scheme -eq 'http') {
            Write-Warning "Connecting to API via insecure HTTP is not recommended!"
        }

        $script:VivantioPSConfig.URI.RPC.Scheme = $Scheme.ToLower()
        $script:VivantioPSConfig.URI.RPC.Scheme
    }
}