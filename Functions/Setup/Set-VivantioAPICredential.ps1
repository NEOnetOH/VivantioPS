function Set-VivantioAPICredential {
    [CmdletBinding(DefaultParameterSetName = 'CredsObject',
                   ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscredential])]
    param
    (
        [Parameter(ParameterSetName = 'CredsObject',
                   Mandatory = $true)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'UserPass',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(ParameterSetName = 'UserPass',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring]$Password
    )

    if ($PSCmdlet.ShouldProcess('Vivantio Credentials', 'Set')) {
        switch ($PsCmdlet.ParameterSetName) {
            'CredsObject' {
                $script:VivantioPSConfig['Credential'] = $Credential
                break
            }

            'UserPass' {
                $script:VivantioPSConfig['Credential'] = [System.Management.Automation.PSCredential]::new($Username, $Password)
                break
            }
        }

        $script:VivantioPSConfig['Credential']
    }
}