
function Set-VivantioRPCTicketStatus {
<#
    .SYNOPSIS
        Update a ticket status

    .DESCRIPTION
        Update/set a ticket's status

    .PARAMETER TicketId
        Database ID of the target ticket

    .PARAMETER StatusId
        Database ID of the target status

    .PARAMETER MarkPrivate
        Set the change to private

    .EXAMPLE
        PS C:\> Set-VivantioRPCTicketStatus -TicketId 12345 -StatusId 152

    .NOTES
        This does not currently support sending any emails

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-ChangeStatus
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$TicketId,

        [Parameter(Mandatory = $true)]
        [uint64]$StatusId,

        [switch]$MarkPrivate,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'ChangeStatus'))
    }

    process {
        $Body = [pscustomobject]@{
            AffectedTickets = ,$TicketId
            StatusId        = $StatusId
            MarkPrivate     = $MarkPrivate.ToString().ToLower()
        }

        $uri = BuildNewURI -Segments $Segments

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $Body
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}
