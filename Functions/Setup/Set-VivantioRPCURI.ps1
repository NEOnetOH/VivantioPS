
function Set-VivantioAPIURI {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$URI,
        
        [switch]$PassThru
    )
    
    $uriBuilder = [System.UriBuilder]::new($URI)
    
    if ($PSCmdlet.ShouldProcess('Vivantio API URI', 'Set')) {
        if ($uriBuilder.Scheme -ieq 'http') {
            Write-Warning "Connecting to API via insecure HTTP is not recommended!"
        }
        
        $script:VivantioPSConfig.URI.RPC = $uriBuilder
    }
    
    if ($PassThru) {
        $script:VivantioPSConfig.URI.RPC
    }
}