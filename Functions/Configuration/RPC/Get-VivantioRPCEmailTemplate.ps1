
function Get-VivantioRPCEmailTemplate {
<#
    .SYNOPSIS
        Get email template types

    .DESCRIPTION
        Get email template types

    .PARAMETER Type
        Get a particular email template by

    .PARAMETER RecordType
        Get the ticket type of the provided TicketID(s)

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Get-VivantioRPCEmailTemplate -TypeId 10

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-EmailTemplateSelectByType_type

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Configuration-EmailTemplateSelectByRecordTypeAndTemplateType_recordType_type
#>

    [CmdletBinding(DefaultParameterSetName = 'SelectByRecordTypeAndTemplateType')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('External', 'Internal', 'PasswordChange', 'Signature', 'EmailRejected', 'ScheduledReport', 'PasswordReset', 'Chat', 'SurveyResult', '0', '1', '2', '3', '4', '5', '6', '7', '8', IgnoreCase = $true)]
        [string]$Type,

        [Parameter(ParameterSetName = 'SelectByRecordTypeAndTemplateType')]
        [ValidateNotNullOrEmpty()]
        [uint64]$RecordType,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))

        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
        }

        $TypeStringToInt = @{
            'External'        = 0
            'Internal'        = 1
            'PasswordChange'  = 2
            'Signature'       = 3
            'EmailRejected'   = 4
            'ScheduledReport' = 5
            'PasswordReset'   = 6
            'Chat'            = 7
            'SurveyResult'    = 8
        }

        $Parameters = @{}

        if ([int]::TryParse($Type, [ref]$null)) {
            $Parameters['type'] = $Type
        } else {
            $Parameters['type'] = $TypeStringToInt[$Type]
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'SelectByRecordTypeAndTemplateType' {
                [void]$Segments.Add('EmailTemplateSelectByRecordTypeAndTemplateType')

                $Parameters['recordType'] = $RecordType

                break
            }

            default {
                [void]$Segments.Add('EmailTemplateSelectByType')

                break
            }
        }

        $paramInvokeVivantioRequest['uri'] = BuildNewURI -Segments $Segments -Parameters $Parameters

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}
