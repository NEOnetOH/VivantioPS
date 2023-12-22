function New-VivantioRPCTicket {
<#
    .SYNOPSIS
        Create a new ticket via RPC

    .DESCRIPTION
        Create a new ticket via RPC

    .PARAMETER RecordTypeId
        The type of ticket (ticket types provided via Get-VivantioRPCTicketType)

    .PARAMETER ClientId
        Database ID of the client

    .PARAMETER CallerId
        Database ID of the caller

    .PARAMETER CategoryId
        Database ID of the category

    .PARAMETER Title
        Title/Subject/Summary

    .PARAMETER Description
        Plain text description for the ticket

    .PARAMETER DescriptionHTML
        HTML description for the ticket

    .PARAMETER GroupId
        Database ID of the group to assign the ticket

    .PARAMETER OwnerId
       Database ID of the user to assign the ticket

    .EXAMPLE
        PS C:\> New-VivantioRPCTicket -RecordTypeId $value1 -ClientId $value2 -CallerId $value3 -CategoryId $value4

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Insert
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$RecordTypeId,

        [Parameter(Mandatory = $true)]
        [uint64]$ClientId,

        [Parameter(Mandatory = $true)]
        [uint64]$CallerId,

        [Parameter(Mandatory = $true)]
        [uint64]$CategoryId,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [string]$Description,

        [string]$DescriptionHTML,

        [uint64]$GroupId,

        [uint64]$OwnerId
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Insert'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        # Parameter validation?
        # TicketType = Get-VivantioRPCTicketType -TypeId $RecordTypeId -ErrorAction Stop

        $Body = @{}

        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            $Body[$Parameter.Key] = $Parameter.Value
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
