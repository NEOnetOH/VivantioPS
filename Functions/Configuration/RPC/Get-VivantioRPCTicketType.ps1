
function Get-VivantioRPCTicketType {
<#
    .SYNOPSIS
        Get ticket types
    
    .DESCRIPTION
        Get ticket types
    
    .PARAMETER All
        Get all ticket types
    
    .PARAMETER TypeId
        Get a particular ticket type by ID
    
    .PARAMETER TicketId
        Get the ticket type of the provided TicketID(s)
    
    .EXAMPLE
        PS C:\> Get-VivantioRPCTicketType
    
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
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true)]
        [uint64]$TypeId,
        
        [Parameter(ParameterSetName = 'SelectByTicketId')]
        [uint64[]]$TicketId
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Configuration'))
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'All' {
                [void]$Segments.Add('TicketTypeSelectAll')
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Raw    = $Raw
                    Method = 'POST'
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            'SelectById' {
                [void]$Segments.AddRange(@('TicketTypeSelectById', $TypeId))
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Raw    = $Raw
                    Method = 'POST'
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            'SelectByTicketId' {
                [void]$Segments.Add('TicketTypeSelectByTicketIds')
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Raw    = $Raw
                    Body   = (,$TicketId | ConvertTo-Json -Compress)
                    Method = 'POST'
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
        }
    }
}
