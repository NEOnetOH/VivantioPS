function Clear-VivantioAPICredential {
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
    param
    (
        [switch]$Force
    )
    
    if ($Force -or ($PSCmdlet.ShouldProcess('Vivantio Credentials', 'Clear'))) {
        $script:VivantioPSConfig['Credential'] = $null
    }
}