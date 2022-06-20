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