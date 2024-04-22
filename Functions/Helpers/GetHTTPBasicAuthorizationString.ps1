
function GetHTTPBasicAuthorizationString {
    [CmdletBinding(DefaultParameterSetName = 'String')]
    [OutputType([string], ParameterSetName = 'String')]
    [OutputType([hashtable], ParameterSetName = 'Hashtable')]
    param
    (
        [Parameter(Mandatory = $false)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'Hashtable')]
        [switch]$Hashtable
    )

    if (-not $PSBoundParameters.ContainsKey('Credential')) {
        if (-not ($Credential = Get-Credential -Message "Please provide credentials")) {
            throw "You must provide credentials"
        }
    }

    $bytes = [System.Text.Encoding]::ASCII.GetBytes($("{0}:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password))
    $base64 = [System.Convert]::ToBase64String($bytes)

    switch ($PSCmdlet.ParameterSetName) {
        'Hashtable' {
            [hashtable]@{
                'Authorization' = "Basic $base64"
            }

            break
        }

        default {
            "Basic $base64"
        }
    }
}
