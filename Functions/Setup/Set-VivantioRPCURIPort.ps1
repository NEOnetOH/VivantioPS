function Set-VivantioAPIURIPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port
    )

    if ($PSCmdlet.ShouldProcess('Vivantio API URI Port', 'Set')) {
        $script:VivantioPSConfig.URI.RPC.Port = $Port
        $script:VivantioPSConfig.URI.RPC.Port
    }
}