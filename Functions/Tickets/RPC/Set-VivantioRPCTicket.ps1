
function Set-VivantioRPCTicket {
<#
    .SYNOPSIS
        Updates the core details of a ticket(s)

    .DESCRIPTION
        Update the core details of one or more tickets

    .PARAMETER TicketUpdateRequest
        A [Vivantio.TicketUpdateRequest] object returned from New-VivantioRPCTicketUpdateRequest

    .EXAMPLE
        PS C:\> Set-VivantioRPCTicket -TicketUpdateRequest $TicketUpdateRequest

    .EXAMPLE
        PS C:\> $Ticket = Get-VivantioRPCTicket -Id 122345
        PS C:\> Set-VivantioRPCTicket `
                  -TicketUpdateRequest (New-VivantioRPCTicketUpdateRequest -TicketBody $Ticket `
                                                                           -Title 'My New Ticket Title' `
                                                                           -ClientId 127 )

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Update
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]$TicketUpdateRequest
    )

    begin {
        if ($TicketUpdateRequest.psobject.TypeNames -notcontains 'Vivantio.TicketUpdateRequest') {
            Write-Error -ErrorRecord ([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Expected type 'Vivantio.TicketUpdateRequest' but got '$($TicketUpdateRequest.psobject.TypeNames[0])' for parameter TicketUpdateRequest"), '1', [System.Management.Automation.ErrorCategory]::InvalidType, $TicketUpdateRequest)) -ErrorAction Stop
        }

        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Update'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $TicketUpdateRequest.CCAddressList = $TicketUpdateRequest.CCAddressList -join '; '

        $paramInvokeVivantioRequest = @{
            URI    = $uri
            Body   = $TicketUpdateRequest
            Raw    = $Raw
            Method = 'POST'
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
}
