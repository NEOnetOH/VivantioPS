
function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Verifying API connectivity"
    
    $uriSegments = [System.Collections.ArrayList]::new(@('Caller', 'SelectById', '1'))

    $uri = BuildNewURI -APIType API -Segments $uriSegments -SkipConnectedCheck

    InvokeVivantioRequest -URI $uri -Method POST -ErrorAction Stop
}