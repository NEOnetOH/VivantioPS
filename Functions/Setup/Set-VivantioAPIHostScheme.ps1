function Set-VivantioAPIHostScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https',
        
        [switch]$OData
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Host Scheme', 'Set')) {
        if ($Scheme -eq 'http') {
            Write-Warning "Connecting via non-secure HTTP is not-recommended"
        }
        
        if ($Odata) {
            $script:VivantioPSConfig['HostSchemeOData'] = $Scheme
            $script:VivantioPSConfig.HostSchemeOData
        } else {
            $script:VivantioPSConfig['HostScheme'] = $Scheme
            $script:VivantioPSConfig.HostScheme
        }
        
    }
}