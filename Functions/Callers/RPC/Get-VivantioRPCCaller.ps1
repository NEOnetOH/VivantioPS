
function Get-VivantioRPCCaller {
    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(ParameterSetName = 'Select',
                   Mandatory = $true)]
        [object]$Query,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [Parameter(ParameterSetName = 'SelectByQueue',
                   Mandatory = $true)]
        [object]$Queue,
        
        [Parameter(ParameterSetName = 'SelectPage',
                   Mandatory = $true)]
        [hashtable]$Page,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Caller'))
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Select' {
                [void]$Segments.Add($_)
                
                $uri = BuildNewURI -Segments $Segments
                
                $paramInvokeVivantioRequest = @{
                    URI    = $uri
                    Body   = $Query
                    Raw    = $Raw
                    Method = 'POST'
                }
                
                if ($Query -is [System.String]) {
                    $paramInvokeVivantioRequest['BodyIsJSON'] = $true
                }
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            'SelectById' {
                $paramInvokeVivantioRequest = @{
                    Raw = $Raw
                    Method = 'POST'
                }
                
                if (@($Id).Count -eq 1) {
                    Write-Verbose "Single ID"
                    [void]$Segments.AddRange(@('SelectById', $Id))
                } else {
                    [void]$Segments.Add('SelectList')
                    
                    Write-Verbose "$(@($Value).Count) IDs to select"
                    $paramInvokeVivantioRequest['Body'] = ,@($Id) | ConvertTo-Json -Compress
                    $paramInvokeVivantioRequest['BodyIsJSON'] = $true
                }
                
                $paramInvokeVivantioRequest['Uri'] = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest @paramInvokeVivantioRequest
                
                break
            }
            
            default {
                throw "'$_' NOT IMPLEMENTED"
            }
        }
    }
    
    end {
        
    }
}
