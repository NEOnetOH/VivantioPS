
class VivantioQueryItem   {
    
    # Class Properties
    [string]$FieldName
    
    [VivantioQueryOperator]$Op
    
    [string]$Value
    
    # Class Constructors
    VivantioQueryItem ([string]$FieldName, [VivantioQueryOperator]$Op, [string]$Value) {
        $this.FieldName = $FieldName
        $this.Op = $Op
        $this.Value = $Value
    }
}
