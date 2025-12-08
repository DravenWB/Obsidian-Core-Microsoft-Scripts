# Global Modules

These functions are used in nearly all of the other functions in the module and can be used to bootstrap new additions. They can still be called individually in order to manually conduct tests such as "Test-OcmsConnection" which is setup to test multiple services either individually or in groups. 

## Connect-OcmsService

### Synopsis
Microsoft service connection tester.

### Description
Microsoft has too many connect commands that all differ for one reason or another. This module allows you to connect to SharePoint, Exchange, IPPS, Graph and PnP PowerShell services by using a single, standardized function call.

### Parameters

| Parameter       | Type     | Required | Description   |
|:---             |:---:     |:---:     |:---           |
| `Service`       | String   | Yes      | Service you are testing. |
| `TenantDomain`  | String   | Yes      | Identifies tenant being connected to |
| `Environment`   | String   | No       | Select MS Environment type such as GCCH |
| `AdminUPN`      | String   | Yes      | Admin UPN running the function for auth. | 

### Examples

#### Example 1 — Connecting to SharePoint (Simplest)
`Connect-OcmsService -Service SharePoint -TenantDomain contoso -AdminUPN john.doe`

### Example 2 - Connecting to IPPS with the German Region
`Connect-OcmsService -Service IPPS -TenantDomain contoso -Environment Germany -AdminUPN john.doe`

### Example 3 - Connecting to the GCCH Exchange Environment
`Connect-OcmsService -Service Exchange -TenantDomain contoso -Environment GCCH -AdminUPN john.doe`

### Planned Updates
- Current version testing and validation.
- Improve standardization to handle differences in requirements for each command.