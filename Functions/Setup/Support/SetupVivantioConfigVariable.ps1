function SetupVivantioConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )

    Write-Verbose "Checking for VivantioConfig hashtable"
    if ((-not ($script:VivantioPSConfig)) -or $Overwrite) {
        Write-Verbose "Creating VivantioConfig hashtable"
        $script:VivantioPSConfig = @{
            'Connected' = $false
            'URI'       = @{
                'API' = [System.UriBuilder]::new()
                'OData' = [System.UriBuilder]::new()
            }
        }
    }

    Write-Verbose "VivantioConfig hashtable already exists"
}