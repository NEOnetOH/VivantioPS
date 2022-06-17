function Set-VivantioInvokeParams {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [array]$InvokeParams
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Invoke Params', 'Set')) {
        $script:VivantioPSConfig.InvokeParams = $InvokeParams
        $script:VivantioPSConfig.InvokeParams
    }
}