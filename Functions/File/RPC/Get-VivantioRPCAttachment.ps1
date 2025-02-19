
function Get-VivantioRPCAttachment {
    <#
    .SYNOPSIS
        Downloads a Vivantio file attachment

    .DESCRIPTION
        Download a file attachment to file by attachment AttachmentGuid

    .PARAMETER AttachmentGuid
        The AttachmentGuid of the attachment

    .PARAMETER OutputPath
        The full path to write the file. Default is the current directory and file name from Vivantio

    .PARAMETER Raw
        Return the raw data from the request

    .EXAMPLE
        PS C:\> Get-VivantioRPCAttachment -AttachmentGuid "a677c710-e131-4944-90ab-aa1c5083d917" -OutputPath "C:\temp\attachment.txt"

    .LINK
        https://webservices-na01.vivantio.com/Help/Api/POST-api-File-AttachmentDownload

    .LINK
        https://webservices-na01.vivantio.com/Help/ResourceModel?modelName=AttachmentDownloadResponse

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('UniqueId')]
        [guid]$AttachmentGuid,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [switch]$Raw
    )

    begin {
        $Segments = [System.Collections.ArrayList]::new(@('File', 'AttachmentDownload'))
    }

    process {
        $uri = BuildNewURI -Segments $Segments

        $Body = [pscustomobject]@{
            AttachmentGuid = $AttachmentGuid.Guid
        }

        $paramInvokeVivantioRequest = @{
            Raw    = $Raw
            Method = 'POST'
            Body   = $Body
            Uri    = $uri
        }

        $result = InvokeVivantioRequest @paramInvokeVivantioRequest

        if ($Raw) {
            return $result
        } elseif ($result.Successful -eq $true) {
            if (-not $OutputPath) {
                $OutputPath = Join-Path -Path $PWD -ChildPath $result.FileName
            }

            [System.IO.File]::WriteAllBytes($OutputPath, [System.Convert]::FromBase64String($result.Content))
            Get-Item -Path $OutputPath
        } else {
            throw $result.ErrorMessages
        }
    }

    end {

    }
}
