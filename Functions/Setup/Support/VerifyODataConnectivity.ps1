
function VerifyODataConnectivity {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Verifying OData connectivity"
    
    $uriSegments = [System.Collections.ArrayList]::new(@('Callers'))
    
    $uriParameters = @{
        '$filter' = 'id eq 1'
    }
    
    $uri = BuildNewURI -APIType OData -Segments $uriSegments -Parameters $uriParameters -SkipConnectedCheck
    
    InvokeVivantioRequest -URI $uri -ErrorAction Stop
}