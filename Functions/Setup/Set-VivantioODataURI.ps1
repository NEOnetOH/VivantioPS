
function Set-VivantioODataURI {
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
    
    if ($PSCmdlet.ShouldProcess('Vivantio OData URI', 'Set')) {
        if ($uriBuilder.Scheme -ieq 'http') {
            Write-Warning "Connecting to OData via insecure HTTP is not recommended!"
        }
        
        $script:VivantioPSConfig.URI.OData = $uriBuilder
    }
    
    if ($PassThru) {
        $script:VivantioPSConfig.URI.OData
    }
}