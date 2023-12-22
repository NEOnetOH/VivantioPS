
function Add-VivantioRPCTicketNote {
<#
    .SYNOPSIS
        Add a new note to a ticket

    .DESCRIPTION
        A detailed description of the Add-VivantioRPCTicketNote function.

    .PARAMETER TicketId
        A description of the TicketId parameter.

    .PARAMETER Notes
        A description of the Notes parameter.

    .PARAMETER MarkPrivate
        A description of the MarkPrivate parameter.

    .PARAMETER EmailTemplateId
        A description of the EmailTemplateId parameter.

    .EXAMPLE
        		PS C:\> Add-VivantioRPCTicketNote -TicketId $value1 -Notes 'Value2' -MarkPrivate

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64[]]$TicketId,

        [Parameter(Mandatory = $true)]
        [string]$Notes,

        [switch]$MarkPrivate,

        [ValidateNotNullOrEmpty()]
        [uint64]$EmailTemplateId
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'AddNote'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = @{
            AffectedTickets = $TicketId
            Notes           = $Notes
            MarkPrivate     = $MarkPrivate.ToBool()
        }

        if ($PSBoundParameters.ContainsKey('EmailTemplateId')) {
            $Body['EmailOptions'] = @{
                CustomerEmailTemplateId = $EmailTemplateId
                ReviewCustomerEmail     = $false
                NotifyOwner             = $true
            }
        }

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $Body
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}

