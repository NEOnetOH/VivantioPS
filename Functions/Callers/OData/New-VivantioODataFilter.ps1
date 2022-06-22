
function New-VivantioODataFilter {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [ValidateSet('caller.contactroles.listserv', 'Id', 'Name', 'FirstName', 'LastName', 'Email', 'Phone', 'ClientId', 'LocationId', 'LocationName', 'ExternalKey', 'CreateDate', 'UpdateDate', 'RecordTypeId', 'Deleted', IgnoreCase = $true)]
        [string]$Property,
        
        [Parameter(Position = 1)]
        [ValidateSet('eq', 'ne', 'gt', 'lt', IgnoreCase = $true)]
        [string]$Operator = 'eq',
        
        [Parameter(Mandatory = $true,
                   Position = 2)]
        [AllowEmptyString()]
        [AllowNull()]
        [object]$Value,
        
        [Parameter(Position = 3)]
        [ValidateSet('String', 'Integer', 'Boolean', IgnoreCase = $true)]
        [string]$ValueType = 'String'
    )
    
    if ($Operator -notin @('eq', 'ne')) {
        Write-Warning "Implementation of [$Operator] may be incomplete by Vivantio and return unexpected results!"
    }
    
    $baseString = "{0}='{1}' {2}" -f '$filter', $Property, $Operator
    
    if ($ValueType -ieq 'string') {
        "{0} '{1}'" -f $baseString, $Value
    } else {
        "{0} {1}" -f $baseString, $Value
    }
}
