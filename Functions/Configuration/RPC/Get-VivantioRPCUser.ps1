
function Get-VivantioRPCUser {
<#
    .SYNOPSIS
        Get a Vivantio user/technian

    .DESCRIPTION
        Get Vivantio user(s) by Id, GroupId, or EmailAddress

    .PARAMETER All
        Get all users

    .PARAMETER Id
        One or more database IDs of user accounts

    .PARAMETER GroupId
        A database Id of a group

    .PARAMETER EmailAddress
        One or more email addresses to search for users

    .EXAMPLE
        PS C:\> Get-VivantioRPCUser -EmailAddress $value1

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectAll

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectByGroupId-id

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-UserSelectById-id
#>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        [Parameter(ParameterSetName = 'All',
                   Mandatory = $true)]
        [switch]$All,

        [Parameter(ParameterSetName = 'Id',
                   Mandatory = $true)]
        [uint64[]]$Id,

        [Parameter(ParameterSetName = 'GroupId',
                   Mandatory = $true)]
        [uint64]$GroupId,

        [Parameter(ParameterSetName = 'EmailAddress',
                   Mandatory = $true)]
        [string[]]$EmailAddress
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            {
                'All' -or 'EmailAddress'
            } {
                [void]$Segments.Add('UserSelectAll')

                break
            }

            'Id' {
                if (@($Id).Count -gt 1) {
                    [void]$Segments.Add('UserSelectAll')
                } else {
                    [void]$Segments.AddRange(@('UserSelectById', $Id))
                }

                break
            }

            'GroupId' {
                [void]$Segments.AddRange(@('UserSelectByGroupId', $GroupId))

                break
            }
        }

        $uri = BuildNewURI -Segments $Segments

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Raw    = $Raw
            Method = 'POST'
        }

        $Results = InvokeVivantioRequest @paramInvokeVivantioRequest

        if ($PSCmdlet.ParameterSetName -eq 'EmailAddress') {
            Write-Verbose "Filtering results on email addresses [$EmailAddress]"

            $Results | Where-Object {
                $_.EmailAddress -in $EmailAddress
            }
        } elseif (@($Id).Count -gt 1) {
            Write-Verbose "Filtering results on IDs [$Id]"

            $Results | Where-Object {
                $_.Id -in $Id
            }
        } else {
            $Results
        }
    }
}
