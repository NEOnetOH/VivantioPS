# VivantioPS

Module for interacting with Vivantio APIs (both RPC and OData)

# Setup
 1. Import the module:
    ```Powershell
    Import-Module VivantioPS
    ```
 2. Connect to the API:
    ```Powershell
    Connect-VivantioAPI -ODataURI 'https://my.vivantio.com/odata/' -RPCURI 'https://webservices-na01.vivantio.com/api/'
    ```
 3. Do things!
    ```Powershell
    Get-VivantioRPCClient -Id 30
    ```
    
# Custom Entities/Custom Forms
It is important to understand the structure of `CustomEntityDefinitions` and how they relate to `FieldDefinitions`, 
`FieldOptions`, and `Entities`:

 1. Custom Entity Definitions are created system wide with the following relevent properties:
    - Id (unique)
    - Name
    - Label
    - FieldOptions
        - An array of `FieldDefinitions`
    - RecordTypeId
        - The associated area of Vivantio by Id (Caller, Client, Ticket, etc..)
    
