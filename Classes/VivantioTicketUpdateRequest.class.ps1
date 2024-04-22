class VivantioTicketUpdateRequest {
    [int]$ClientId
    [int]$LocationId
    [int]$CallerId
    [string]$CallerName
    [string]$CallerEmail
    [string]$CallerPhone
    [datetime]$OpenDate
    [int]$TakenById
    [int]$ImpactId
    [string]$Title
    [string]$Description
    [string]$DescriptionHtml
    [string]$CCAddressList
    [int[]]$AffectedTickets
    [int]$Effort
    [string]$Notes
    [string]$NotesHtml
    [bool]$MarkPrivate

    VivantioTicketUpdateRequest(){
      $this.Init(@{})
    }
    #VivantioTicketUpdateRequest() {
    #    $this.ClientId = $null
    #    $this.LocationId = $null
    #    $this.CallerId = $null
    #    $this.CallerName = $null
    #    $this.CallerEmail = $null
    #    $this.CallerPhone = $null
    #    $this.OpenDate = $null
    #    $this.TakenById = $null
    #    $this.ImpactId = $null
    #    $this.Title = $null
    #    $this.Description = $null
    #    $this.DescriptionHtml = $null
    #    $this.CCAddressList = $null
    #    $this.AffectedTickets = $null
    #    $this.Effort = $null
    #    $this.Notes = $null
    #    $this.NotesHtml = $null
    #    $this.MarkPrivate = $false
    #}

    VivantioTicketUpdateRequest([pscustomobject]$TicketBody) {
        $this.ClientId = $TicketBody.ClientId
        $this.LocationId = $TicketBody.LocationId
        $this.CallerId = $TicketBody.CallerId
        $this.CallerName = $TicketBody.CallerName
        $this.CallerEmail = $TicketBody.CallerEmail
        $this.CallerPhone = $TicketBody.CallerPhone
        $this.OpenDate = $TicketBody.OpenDate
        $this.TakenById = $TicketBody.TakenById
        $this.ImpactId = $TicketBody.ImpactId
        $this.Title = $TicketBody.Title
        $this.Description = $TicketBody.Description
        $this.DescriptionHtml = $TicketBody.DescriptionHtml
        $this.CCAddressList = $TicketBody.CCAddressList
        $this.AffectedTickets = $TicketBody.AffectedTickets
        $this.Effort = $TicketBody.Effort
        $this.Notes = $TicketBody.Notes
        $this.NotesHtml = $TicketBody.NotesHtml
        $this.MarkPrivate = $TicketBody.MarkPrivate
    }

    VivantioTicketUpdateRequest([int]$ClientId, [int]$LocationId, [int]$CallerId, [string]$CallerName, [string]$CallerEmail, [string]$CallerPhone, [datetime]$OpenDate, [int]$TakenById, [int]$ImpactId, [string]$Title, [string]$Description, [string]$DescriptionHtml, [string]$CCAddressList, [int[]]$AffectedTickets, [int]$Effort, [string]$Notes, [string]$NotesHtml, [bool]$MarkPrivate) {
        $this.ClientId = $ClientId
        $this.LocationId = $LocationId
        $this.CallerId = $CallerId
        $this.CallerName = $CallerName
        $this.CallerEmail = $CallerEmail
        $this.CallerPhone = $CallerPhone
        $this.OpenDate = $OpenDate
        $this.TakenById = $TakenById
        $this.ImpactId = $ImpactId
        $this.Title = $Title
        $this.Description = $Description
        $this.DescriptionHtml = $DescriptionHtml
        $this.CCAddressList = $CCAddressList
        $this.AffectedTickets = $AffectedTickets
        $this.Effort = $Effort
        $this.Notes = $Notes
        $this.NotesHtml = $NotesHtml
        $this.MarkPrivate = $MarkPrivate
    }
}