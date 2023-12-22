function Set-VivantioODataURIScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https'
    )

    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Scheme', 'Set')) {
        if ($Scheme -ieq 'http') {
            Write-Warning "Connecting to OData via insecure HTTP is not recommended!"
        }

        $script:VivantioPSConfig.URI.OData.Scheme = $Scheme.ToLower()
        $script:VivantioPSConfig.URI.OData.Scheme
    }
}