
class VivantioQuery   {
    
    # Class Properties
    [VivantioQueryMode]$Mode
    
    [VivantioQueryItem[]]$Items
    
    # Class Constructors
    VivantioQuery ([VivantioQueryMode]$Mode, [VivantioQueryItem[]]$Items) {
        $this.Mode = $Mode
        $this.Items = $Items
    }
    
    
}

