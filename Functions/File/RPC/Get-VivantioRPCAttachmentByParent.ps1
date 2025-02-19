
function Get-VivantioRPCAttachmentByParent {
<#
    .SYNOPSIS
        Get a Vivantio file attachment information

    .DESCRIPTION
        Get a file attachment information by the parent ID and area

    .PARAMETER ParentId
        The database ID of the ticket

    .PARAMETER ParentArea
        The area of the parent object. Valid values are 'Article', 'Asset', 'Caller', 'Client', 'Location', 'Ticket'. Default is 'Ticket'

    .PARAMETER Raw
        Return the raw data from the request

    .EXAMPLE
        PS C:\> Get-VivantioRPCAttachmentByParent -ParentId 12345 -ParentArea 'Ticket'

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-File-AttachmentSelectByParent_parentId_parentArea

    .LINK
        https://webservices-na01.vivantio.com/Help/ResourceModel?modelName=SelectResponseOfAttachment
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64[]]$ParentId,

        [Parameter()]
        [ValidateSet('Article', 'Asset', 'Caller', 'Client', 'Location', 'Ticket', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParentArea = 'Ticket',

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('File', 'AttachmentSelectByParent'))
    }

    process {
        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
        }

        $paramInvokeVivantioRequest['Uri'] = BuildNewURI -Segments $Segments -Parameters @{
            ParentId   = $ParentId
            ParentArea = $ParentArea
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }

    end {

    }
}
