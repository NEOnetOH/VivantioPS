function Set-VivantioAPIHostName {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        
        [switch]$OData
    )
    
    if ($PSCmdlet.ShouldProcess('Vivantio Hostname', 'Set')) {
        if ($OData) {
            $script:VivantioPSConfig['HostnameOData'] = $Hostname.Trim()
            $script:VivantioPSConfig.HostnameOData
        } else {
            $script:VivantioPSConfig['Hostname'] = $Hostname.Trim()
            $script:VivantioPSConfig.Hostname
        }
    }
}