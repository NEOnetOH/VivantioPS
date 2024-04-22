
function New-VivantioRPCTicketUpdateRequest {
<#
    .SYNOPSIS
        Create a ticket update request

    .DESCRIPTION
        Create a ticket update request to supply to Set-VivantioRPCTicket. If you provide an existing ticket,
        this will pre-populate the appropriate fields. If you specify other parameters, those will override
        the values provided in $TicketBody

    .PARAMETER TicketBody
        The ticket details returned by Get-VivantioRPCTicket

    .PARAMETER ClientId
        The internal ID of the Client

    .PARAMETER LocationId
        The internal ID of the Location

    .PARAMETER CallerId
        The internal ID of the caller

    .PARAMETER CallerName
        The name for the caller

    .PARAMETER CallerEmail
        The email for the caller

    .PARAMETER CallerPhone
        The phone number for the caller

    .PARAMETER OpenDate
        The date the ticket opened

    .PARAMETER TakenById
        The internal ID of the owning technician

    .PARAMETER ImpactId
        The internal ID of the impact level

    .PARAMETER Title
        The title of the ticket

    .PARAMETER Description
        The plain-text description

    .PARAMETER DescriptionHTML
       The HTML description

    .PARAMETER CCAddressList
        One or more email addresses to CC ticket updates

    .PARAMETER AffectedTickets
        The internal IDs of the tickets this operation applies to.

    .PARAMETER Effort
        The Effort, in minutes, to record in the ticket history

    .PARAMETER Notes
        The notes to add to the ticket history, in plain-text format. This property cannot be combined with the
        NotesHtml property.

    .PARAMETER NotesHTML
        The notes to add to the ticket history, in HTML format. This property cannot be combined with the
        Notes property.

    .PARAMETER MarkPrivate
        Flag indicating whether or not this operation should be considered Private. Emails cannot be sent for Private
        actions, and they cannot be viewed in the Self Service Portal.

    .EXAMPLE
        PS C:\> New-VivantioRPCTicketUpdateRequest

    .OUTPUTS
        Vivantio.TicketUpdateRequest

    .NOTES
        Additional information about the function.

    .LINK
        https://webservices-na01.vivantio.com/Help/ResourceModel?modelName=TicketUpdateRequest
#>

    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Position = 0)]
        [psobject]$TicketBody,

        [uint64]$ClientId,

        [uint64]$LocationId,

        [uint64]$CallerId,

        [string]$CallerName,

        [string]$CallerEmail,

        [string]$CallerPhone,

        [datetime]$OpenDate,

        [uint64]$TakenById,

        [uint64]$ImpactId,

        [string]$Title,

        [string]$Description,

        [string]$DescriptionHTML,

        [string[]]$CCAddressList,

        [uint64[]]$AffectedTickets,

        [uint64]$Effort,

        [string]$Notes,

        [string]$NotesHTML,

        [switch]$MarkPrivate
    )

    begin {
        if ($PSBoundParameters.ContainsKey('Notes') -and $PSBoundParameters.ContainsKey('NotesHTML')) {
            Write-Error -ErrorRecord ([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Only ONE of parameters 'Notes' or 'NotesHTML' may be provided."), '1', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)) -ErrorAction Stop
        }

        $UR = [pscustomobject]@{
            "ClientId"        = $null # int
            "LocationId"      = $null # int
            "CallerId"        = $null # int
            "CallerName"      = $null # string
            "CallerEmail"     = $null # string
            "CallerPhone"     = $null # string
            "OpenDate"        = $null # date
            "TakenById"       = $null # int
            "ImpactId"        = $null # int
            "Title"           = $null # string
            "Description"     = $null # string
            "DescriptionHtml" = $null # string
            "CCAddressList"   = $null # string
            "AffectedTickets" = $null # Collection of int
            "Effort"          = $null # int
            "Notes"           = $null # string
            "NotesHtml"       = $null # string
            "MarkPrivate"     = $false # Bool
        }
    }

    process {
        if ($PSBoundParameters.ContainsKey('TicketBody')) {
            $UR.ClientId = $TicketBody.ClientId
            $UR.LocationId = $TicketBody.LocationId
            $UR.CallerId = $TicketBody.CallerId
            $UR.CallerName = $TicketBody.CallerName
            $UR.CallerEmail = $TicketBody.CallerEmail
            $UR.CallerPhone = $TicketBody.CallerPhone
            $UR.OpenDate = $TicketBody.OpenDate
            $UR.TakenById = $TicketBody.TakenById
            $UR.ImpactId = $TicketBody.ImpactId
            $UR.Title = $TicketBody.Title
            $UR.Description = $TicketBody.Description
            $UR.DescriptionHtml = $TicketBody.DescriptionHtml
            $UR.CCAddressList = @($TicketBody.CCAddressList -split ';').Trim()
            $UR.AffectedTickets = @($TicketBody.Id)
            $UR.Effort = $TicketBody.Effort
        }

        :ParameterLoop foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            switch ($Parameter.Key) {
                'TicketBody' {
                    continue ParameterLoop
                }

                'AffectedTickets' {
                    $UR.AffectedTickets = @($AffectedTickets)
                }

                default {
                    $UR.$_ = $Parameter.Value
                    break
                }
            }

        }

        $UR.psobject.typenames.insert(0, "Vivantio.TicketUpdateRequest")

        return $UR
    }
}











