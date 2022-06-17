function Set-VivantioODataURIPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI Port', 'Set')) {
        $script:VivantioPSConfig.URI.OData.Port = $Port
        $script:VivantioPSConfig.URI.OData.Port
    }
}