function Set-VivantioAPIURIHost {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname
    )

    if ($PSCmdlet.ShouldProcess('Vivantio API URI Host', 'Set')) {
        $script:VivantioPSConfig.URI.RPC.Host = $Hostname.Trim()
        $script:VivantioPSConfig.URI.RPC.Host
    }
}