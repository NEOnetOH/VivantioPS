function Add-VivantioRPCTicketAttachment {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64]$TicketId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$FilePath,

        [Parameter()]
        [ValidateSet('Article', 'Asset', 'Caller', 'Client', 'Location', 'Ticket', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SystemArea = 'Ticket',

        [Parameter()]
        [string]$Description,

        [switch]$MarkPrivate
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('File', 'AttachmentUpload'))
    }

    process {
        if (-not (Test-Path -Path $FilePath.FullName)) {
            throw "File not found: $($FilePath.FullName)"
        }

        $uri = BuildNewURI -Segments $Segments

        $Body = [pscustomobject]@{
            'ParentId'    = $TicketId
            'SystemArea'  = $SystemArea
            'Description' = $Description
            'IsPrivate'   = $MarkPrivate.ToString()
            'FileName'    = $FilePath.Name
            'Content'     = [System.IO.File]::ReadAllBytes($FilePath.FullName)
        }

        InvokeVivantioRequest -URI $uri -Body $Body -Method POST
    }
}
