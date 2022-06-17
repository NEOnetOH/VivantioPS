function Set-VivantioAPIHostPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port,
        
        [switch]$OData
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio Port', 'Set')) {
        if ($OData) {
            $script:VivantioPSConfig['HostPortOData'] = $Port
            $script:VivantioPSConfig.HostPortOData
        } else {
            $script:VivantioPSConfig['HostPort'] = $Port
            $script:VivantioPSConfig.HostPort
        }
    }
}