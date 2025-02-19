function Close-VivantioRPCTicket {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64]$TicketId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Solution,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64]$CloseStatusId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Notes,

        [Parameter()]
        [switch]$EmailCustomer,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [uint64]$CustomerEmailTemplateId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [uint64[]]$AttachmentId,

        [switch]$MarkPrivate

    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Ticket', 'Close'))
    }

    process {
        if ($EmailCustomer -and (-not $PSBoundParameters.ContainsKey('CustomerEmailTemplateId'))) {
            throw 'CustomerEmailTemplateId is required when EmailCustomer is specified'
        }

        if ($PSBoundParameters.ContainsKey('AttachmentId')) {
            $Attachments = [System.Collections.ArrayList]::new()

            foreach ($AID in $AttachmentId) {
                $EmbeddedAttachment = @{
                    ExistingAttachmentId = $AID
                }

                [void]$Attachments.Add($EmbeddedAttachment)
            }
        }

        $uri = BuildNewURI -Segments $Segments

        $Body = [hashtable]@{
            CloseStatusId = $CloseStatusId
            AffectedTickets  = ,$TicketId
            Solution      = $Solution
            MarkPrivate   = $MarkPrivate.ToBool()
            EmailCustomer = $EmailCustomer.ToBool()
        }

        if ($PSBoundParameters.ContainsKey('Notes')) {
            $Body['Notes'] = $Notes
        }

        if ($EmailCustomer) {
            $Body['EmailOptions'] = @{
                CustomerEmailTemplateId = $CustomerEmailTemplateId
                ReviewCustomerEmail = $false
                NotifyOwner = $false
            }
        }

        if ($PSBoundParameters.ContainsKey('AttachmentId')) {
            $Body['Attachments'] = $Attachments
        }

        $paramInvokeVivantioRequest = @{
            Method = 'POST'
            Body   = $Body
            Uri    = $uri
        }

        InvokeVivantioRequest @paramInvokeVivantioRequest
    }

    end {

    }
}