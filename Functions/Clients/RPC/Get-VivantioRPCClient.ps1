
function Get-VivantioRPCClient {
    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Mandatory = $true)]
        [object]$Query,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@('Client'))
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Query' {
                [void]$Segments.Add('Select')
                
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
                Write-Verbose "$(@($Value).Count) IDs to select"
                
                if (@($Id).Count -eq 1) {
                    [void]$Segments.AddRange(@('SelectById', $Id))
                    $Body = @{} | ConvertTo-Json -Compress
                } else {
                    [void]$Segments.Add('SelectList')
                    $Body = @($Id) | ConvertTo-Json -Compress
                }
                
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body $Body -BodyIsJSON -Raw:$Raw -Method POST
                
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
