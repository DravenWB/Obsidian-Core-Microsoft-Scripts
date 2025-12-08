# Global Modules
These functions are used in nearly all of the other functions in the module and can be used to bootstrap new additions. They can still be called individually in order to manually conduct tests such as "Test-OcmsConnection" which is setup to test multiple services either individually or in groups. 

&nbsp;

## Connect-OcmsService

### Synopsis
Microsoft service connection tester.

### Description
Microsoft has too many connect commands that all differ for one reason or another. This module allows you to connect to SharePoint, Exchange, IPPS, Graph and PnP PowerShell services by using a single, standardized function call.

### Parameters

| Parameter       | Type     | Required | Defaults | Description   |
|:---             |:---:     |:---:     |:--- | :---           |
| `Service`       | String   | Yes      | None | Service you are testing. |
| `TenantDomain`  | String   | Yes      | None | Identifies tenant being connected to. |
| `Environment`   | String   | No       | Commercial | Select MS Environment type such as GCCH. |
| `AdminUPN`      | String   | Yes      | None | Admin UPN running the function for auth. | 

### Examples

#### Connecting to SharePoint (Simplest)
`Connect-OcmsService -Service SharePoint -TenantDomain contoso -AdminUPN john.doe`

### Connecting to IPPS with the German Region
`Connect-OcmsService -Service IPPS -TenantDomain contoso -Environment Germany -AdminUPN john.doe`

### Connecting to the GCCH Exchange Environment
`Connect-OcmsService -Service Exchange -TenantDomain contoso -Environment GCCH -AdminUPN john.doe`

### Planned Updates
- Current version testing and validation.
- Improve standardization to handle differences in requirements for each command.

&nbsp;

## Test-OcmsConnection

### Synopsis
Tests the connection of multiple services as a bootstrap utility.

### Description
Validates connectivity to SharePoint, Exchange, IPPS (Information Protection & Policy Service), Microsoft Graph, and PnP PowerShell. This function is typically used as a bootstrap check before running larger scripts or modules that depend on these connections.

The function accepts multiple service names and consolidates all failures. By default, the function throws on any connection failure so that parent scripts can exit early.

### Parameters

| Parameter       | Type     | Required | Defaults | Description   |
|:---             |:---:     |:---:     |:---      | :---           |
| `Service`       | String   | Yes      | None     | Service you are testing. |
| `ThrowOnFail`   | Boolean  | No       | $True    | Whether or not to exit the program on test failure. |

### Examples

#### Testing a Single SharePoint Connection
`Test-OcmsConnection -Service SharePoint`

#### Testing Multiple Services
`Test-OcmsConnection -Service SharePoint, Exchange, IPPS`

#### Setting the ThrowOnFail flag.
`Test-OcmsConnection -Service SharePoint -ThrowOnFail $false`

### Planned Updates
- Testing and debugging

&nbsp;

## Test-OcmsModule

### Synopsis
Module installation tester with installation flags.

### Description
This function allows you to test for whether a module is installed or not. Additionally has flags to automatically install a module for you, if missing, and throw on failure.

### Parameters

| Parameter       | Type     | Required | Defaults   | Description   |
|:---             |:---:     |:---:     |:---        | :---           |
| `Version`       | Version   | Yes      | None      | Module version you are testing against. |
| `Module`        | String   | Yes      | None       | Normalized name of module being tested. |
| `ThrowOnFail`   | Boolean   | No       | $True | Whether or not to stop operations on test failure. |
| `AutoInstall`   | Boolean   | No      | $False       | Whether or not to test automatic installation if tested module is not found. | 

### Examples

#### Testing Powershell Version
`Test-OcmsModule -Module PowerShell -Version 7`

#### Testing SharePoint Management Shell Installation With Install Flags
`Test-OcmsModule -Module SharePoint -Version 16.0.267 -AutoInstall $true`

#### Disabling the ThrowOnFail Flag
`Test-OcmsModule -Module PowerShell -Version 5 -ThrowOnFail $false`

### Planned Updates
- Testing and debugging

&nbsp;

## Write-OcmsLog

### Synopsis
Unified object logging module.

### Description
Module used for all OCMS log handling. Includes two-stage automated naming conflict handling to prevent data loss in case of long script operation. Typically involves lists and tables.

### Parameters

| Parameter       | Type     | Required | Defaults   | Description   |
|:---             |:---:     |:---:     |:---        | :---           |
| `Data`          | Object   | Yes      | None       | Object passed in for logging. |
| `FileName`      | String   | No       | ocms-log.csv | Name of the log to be output. |
| `LogPath`       | String   | No       | User Desktop | Location the file will be saved to. |
| `ThrowOnFail`   | String   | No       | $False       | Whether to stop operations if logging fails. | 

### Examples

#### Basic Usage
`Write-OcmsLog -Data $object`

#### Setting the FileName
`Write-OcmsLog -Data $object -FileName ChangeReport.csv`

#### Setting the LogPath and FileName
`Write-OcmsLog -Data $object -LogPath ~/Documents/Logs/ -FileName ChangeReport.csv`

### Planned Updates
- Testing and debugging if required.