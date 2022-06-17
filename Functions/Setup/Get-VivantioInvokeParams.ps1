function Get-VivantioInvokeParams {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Vivantio InvokeParams"
    if ($null -eq $script:VivantioPSConfig.InvokeParams) {
        throw "Vivantio Invoke Params is not set! You may set it with Set-VivantioInvokeParams -InvokeParams ..."
    }

    $script:VivantioPSConfig.InvokeParams
}