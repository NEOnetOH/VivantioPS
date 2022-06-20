
function VerifyRPCConnectivity {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Verifying RPC API connectivity"
    
    $uriSegments = [System.Collections.ArrayList]::new(@('Caller', 'SelectById', '1'))

    $uri = BuildNewURI -APIType RPC -Segments $uriSegments -SkipConnectedCheck

    InvokeVivantioRequest -URI $uri -Method POST -ErrorAction Stop
}