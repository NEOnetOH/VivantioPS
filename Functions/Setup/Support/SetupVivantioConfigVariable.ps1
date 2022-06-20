function SetupVivantioConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )

    Write-Verbose "Checking for VivantioConfig hashtable"
    if (($null -eq $script:VivantioPSConfig) -or $Overwrite) {
        Write-Verbose "Creating VivantioConfig hashtable"
        $script:VivantioPSConfig = @{
            'Connected' = $false
            'ConnectedTimestamp' = $null
            'URI'       = [pscustomobject]@{
                'RPC' = [System.UriBuilder]::new()
                'OData' = [System.UriBuilder]::new()
            }
        }
    } else {
        Write-Warning "Cannot overwrite VivantioConfig without -Overwrite parameter!"
    }
}