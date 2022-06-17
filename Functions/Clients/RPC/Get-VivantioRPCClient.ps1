
function Get-VivantioRPCClient {
    [CmdletBinding(DefaultParameterSetName = 'SelectById')]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Select', 'SelectById', 'SelectByQueue', 'SelectPage', IgnoreCase = $true)]
        [string]$Method = 'SelectById',
        
        [Parameter(ParameterSetName = 'Select',
                   Mandatory = $true)]
        [hashtable]$Query,
        
        [Parameter(ParameterSetName = 'SelectById',
                   Mandatory = $true)]
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
        switch ($Method) {
            'Select' {
                throw "'SELECT' NOT IMPLEMENTED"
                [void]$Segments.Add($Method)
                
                break
            }
            
            'SelectByIdOld' {
                [void]$Segments.Add('SelectById')
                [void]$Segments.Add(':id') # Placeholder to edit later
                
                Write-Verbose "$(@($Value).Count) IDs to select"
                
                foreach ($v in $Value) {
                    $Id = $null
                    
                    if (-not [uint64]::TryParse($v, [ref]$Id)) {
                        Write-Error -Exception ([System.Exception]::new("[$v] from provided Value array is not a valid uint64 value")) -Category InvalidType -TargetObject $v
                        continue
                    }
                    
                    Write-Verbose "Selecting by Id '$Id'"
                    
                    $Segments[-1] = $Id
                    
                    $uri = BuildNewURI -Segments $Segments
                    
                    InvokeVivantioRequest -URI $uri -Raw:$Raw -Method POST
                }
                
                break
            }
            
            'SelectById' {
                [void]$Segments.Add('SelectList')
                
                Write-Verbose "$(@($Value).Count) IDs to select"
                
                #TODO: This JSON is returning nothing from the API, like it is in an invalid format or something
                $IDListJSON = ,@($Id) | ConvertTo-Json -Compress
                $uri = BuildNewURI -Segments $Segments
                
                InvokeVivantioRequest -URI $uri -Body $IDListJSON -Raw:$Raw -Method POST
                
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
