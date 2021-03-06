
function Get-VivantioRPCClient {
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
        $Segments = [System.Collections.ArrayList]::new(@('Client'))
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
                [void]$Segments.Add('SelectList')
                
                Write-Verbose "$(@($Value).Count) IDs to select"
                $IDListJSON = ,@($Id) | ConvertTo-Json -Compress
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body $IDListJSON -BodyIsJSON -Raw:$Raw -Method POST
                
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
