
function Clear-VivantioAPIProxy {
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
    param
    (
        [switch]$Force
    )

    if ($Force -or ($PSCmdlet.ShouldProcess('Vivantio API Proxy', 'Clear'))) {
        $script:VivantioPSConfig['Proxy'] = $null
    }
}
