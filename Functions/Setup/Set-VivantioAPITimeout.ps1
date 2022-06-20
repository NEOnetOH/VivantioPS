
function Set-VivantioAPITimeout {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Timeout', 'Set')) {
        $script:VivantioPSConfig.Timeout = $TimeoutSeconds
        $script:VivantioPSConfig.Timeout
    }
}