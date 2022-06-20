

enum VivantioQueryOperator {
    Equals = 0
    DoesNotEqual = 1
    GreaterThan = 2
    GreaterThanOrEqualTo = 3
    LessThan = 4
    LessThanOrEqualTo = 5
    Like = 6
}

enum VivantioQueryMode {
    MatchAny = 0
    MatchAll = 1
    MatchNone = 2
}

class VivantioQueryItem   {
	
	# Class Properties
    [string]$FieldName
    
    [VivantioQueryOperator]$Op
    
    [string]$Value
	
	#Hidden Properties
	#hidden [int]$MyHiddenProperty
	
	# Class Constructors
	VivantioQueryItem ($FieldName, $Op, $Value)
	{
		$this.FieldName = $FieldName
        $this.Op = $Op
        $this.Value = $Value
	}
	
	#Class Methods
	[void]MyMethod([string]$parameter1)
	{
		#TODO: Insert method script.
	}
	
	#Static Class Methods
	static [Boolean] MyStaticMethod ([int]$parameter)
	{
		if ($parameter -gt 0)
		{
			return $true
		}
		else
		{
			return $false
		}
	}
}

class VivantioQuery   {
	
	# Class Properties
    [VivantioQueryMode]$Mode
    
    [VivantioQueryItem[]]$Items
	
	# Class Constructors
	VivantioQuery ([VivantioQueryMode]$Mode, [VivantioQueryItem[]]$Items)
	{
        $this.Mode = $Mode
        $this.Items = $Items
	}
	
	#Class Methods
	[void]MyMethod([string]$parameter1)
	{
		#TODO: Insert method script.
	}
	
	#Static Class Methods
	static [Boolean] MyStaticMethod ([int]$parameter)
	{
		if ($parameter -gt 0)
		{
			return $true
		}
		else
		{
			return $false
		}
	}
}

#Sample code to instantiate the class
#$myClassObject = [VivantioQuery]::new()

#Invoke a static method
#[VivantioQuery]::MyStaticMethod(1)

