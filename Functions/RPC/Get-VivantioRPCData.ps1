
<#
function Get-VivantioRPCData {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Article', 'Asset', 'Caller', 'Client', 'Entity', 'Location', 'Ticket', IgnoreCase = $true)]
        [string]$Endpoint,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Select', 'SelectById', 'SelectByQueue', 'SelectList', 'SelectPage', IgnoreCase = $true)]
        [string]$Method = 'SelectById',
        
        [Parameter(Mandatory = $true)]
        [string[]]$Value,
        
        [switch]$Raw
    )
    
    begin {
        $Segments = [System.Collections.ArrayList]::new(@($Endpoint, $Method))
    }
    
    process {
        switch ($Method) {
            'Select' {
                
                break
            }
            
            'SelectById' {
                [void]$Segments.Add(':id')
                
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
        }
    }
    
    end {
        
    }
}
#>


