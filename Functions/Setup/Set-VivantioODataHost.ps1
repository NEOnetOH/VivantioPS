function Set-VivantioODataURIHost {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Host
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Host', 'Set')) {
        $script:VivantioPSConfig.URI.OData.Host = $Host.Trim()
        $script:VivantioPSConfig.URI.OData.Host
    }
}