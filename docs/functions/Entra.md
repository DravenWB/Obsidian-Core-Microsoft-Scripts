# Entra Modules

&nbsp;

## Invoke-OcmsLicenseMigration

### Synopsis
Tailor made license migration tool.

### Description
This tool manually identifies all users in a tenant with a license, and replaces that license in case license grouping is not setup for a tenant.

### Parameters

| Parameter       | Type     | Required | Defaults   | Description   |
|:---             |:---:     |:---:     |:---        | :---           |
| `LicenseToAdd`  | String   | Yes      | None       | This is the license that should be given to a user. |
| `LicenseToRemove` | String | Yes      | None       | This parameter is used to remove a license from a user and is used to identify users to apply the LicenseToAdd. |
| `LogPath`       | String   | No       | User Desktop | This parameter sets the location you would like logs to be saved to. |
| `FileName`      | String   | No       | LicenseMigrationLog.csv | The name of the log file you wish to save. | 

### Examples

#### Basic Usage
`Invoke-OcmsLicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3`

#### Setting the FileName
`Invoke-OcmsLicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3 -LogPath ~/Documents/Logs/ -FileName LicenseMigrationLog.csv`

#### Setting the LogPath and FileName
`Invoke-OcmsLoicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3 -FileName LicenseMigrationLog.csv`

### Planned Updates
- Allow for and handle multiple license input.
- Allow for license assignment without removing a license.
- Allow for license removal without applying a replacement license.
