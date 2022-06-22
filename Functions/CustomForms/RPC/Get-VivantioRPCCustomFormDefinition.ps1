
function Get-VivantioRPCCustomFormDefinition {
<#
    .SYNOPSIS
        Get the custom form definition
    
    .DESCRIPTION
        Provided the definition ID or RecordTypeId, get the system-wide custom form definition
    
    .PARAMETER Id
        Database ID of the form definition
    
    .PARAMETER RecordTypeId
        A description of the RecordTypeId parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        		PS C:\> Get-VivantioRPCCustomFormDefinition -RecordTypeId $value1
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint64]$Id,
        
        [Parameter(ParameterSetName = 'ByRecordTypeId',
                   Mandatory = $true)]
        [uint64]$RecordTypeId,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Entity'))
        $paramInvokeVivantioRequest = @{
            URI    = $null
            Method = 'POST'
            Raw    = $Raw
        }
    }
    
    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ById' {
                [void]$Segments.AddRange(@('CustomEntityDefinitionSelectById', $Id))
                
                break
            }
            
            'ByRecordTypeId' {
                [void]$Segments.Add('CustomEntityDefinitionSelectByRecordTypeId')
                
                $paramInvokeVivantioRequest['Body'] = @{
                    'Id' = $RecordTypeId
                }
                
                break
            }
        }
        
        $paramInvokeVivantioRequest.URI = BuildNewURI -Segments $Segments
        
        InvokeVivantioRequest @paramInvokeVivantioRequest
    }
    
    end {
        
    }
}
