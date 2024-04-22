
function Get-VivantioRPCTicketType {
<#
    .SYNOPSIS
        Get ticket types

    .DESCRIPTION
        Get ticket types

    .PARAMETER NameSingular
        Get ticket type with this particular singular name

    .PARAMETER All
        Get all ticket types

    .PARAMETER TypeId
        Get a particular ticket type by ID

    .PARAMETER TicketId
        Get the ticket type of the provided TicketID(s)

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType -TypeId 100

    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType -NameSingular 'Ticket'

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Select

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectById-id

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-SelectList
#>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        [Parameter(ParameterSetName = 'NameSingular')]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string[]]$NameSingular,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64]$TypeId,

        [Parameter(ParameterSetName = 'SelectByTicketId')]
        [ValidateNotNullOrEmpty()]
        [uint64[]]$TicketId,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))

        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            { 'All' -or 'NameSingular' } {
                [void]$Segments.Add('TicketTypeSelectAll')

                break
            }

            'SelectById' {
                [void]$Segments.AddRange(@('TicketTypeSelectById', $TypeId))

                break
            }

            'SelectByTicketId' {
                [void]$Segments.Add('TicketTypeSelectByTicketIds')

                $paramInvokeVivantioRequest['Body'] = ( ,$TicketId | ConvertTo-Json -Compress)

                break
            }
        }

        $paramInvokeVivantioRequest['uri'] = BuildNewURI -Segments $Segments

        $Result = InvokeVivantioRequest @paramInvokeVivantioRequest

        if ($Raw) {
            Write-Warning "Raw parameter overrides filter for NameSingular"
            return $Result
        }

        if ($PsCmdlet.ParameterSetName -eq 'NameSingular') {
            $Result | Where-Object {
                $_.NameSingular -in $NameSingular
            }
        } else {
            $Result
        }
    }
}
