
function Set-VivantioRPCTicket {
<#
    .SYNOPSIS
        Updates the core details of a Ticket
    
    .DESCRIPTION
        A detailed description of the Set-VivantioRPCTicket function.
    
    .PARAMETER Body
        The properties to update, including ticket ID. 
        https://webservices-na01.vivantio.com/Help/ResourceModel?modelName=TicketUpdateRequest
    
    .EXAMPLE
        PS C:\> Set-VivantioRPCTicket -Body $value1
    
    .NOTES
        Additional information about the function.
    
    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-Ticket-Update
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable]$Body
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Update'))
    }
    
    process {
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
