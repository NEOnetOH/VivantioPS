
function Get-VivantioVersion {
    [CmdletBinding()]
    param ()

    $Segments = [System.Collections.ArrayList]::new(@('status'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{
        'format' = 'json'
    }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeVivantioRequest -URI $URI
}
