function Invoke-OcmsLicenseMigration {
    [CmdletBinding(SupportsShouldProcess=$true)]

    <#
    .SYNOPSIS
    Tailor made license migration tool.

    .DESCRIPTION
    This tool manually identifies all users in a tenant with a license, and replaces that license in case Active Directory group is not setup for a tenant.

    .PARAMETER LicenseToAdd
    This is the license that should be given to a user. Use the License String ID from: https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference

    .PARAMETER LicenseToRemove
    This parameter is used to remove a license from a user and is used to identify users to apply the LicenseToAdd. Use the License String ID from: https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference

    .PARAMETER LogPath
    This parameter sets the location you would like logs to be saved to.
    Default: User desktop

    .PARAMETER FileName
    The name of the log file you wish to save.
    Default: LicenseMigrationLog.csv

    .EXAMPLE
    Invoke-OcmsLicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3

    .EXAMPLE
    Invoke-OcmsLicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3 -LogPath ~/Documents/Logs/ -FileName LicenseMigrationLog.csv

    .EXAMPLE
    Invoke-OcmsLoicenseMigration -LicenseToAdd SPE_E5 -LicenseToRemove SPE_E3 -FileName LicenseMigrationLog.csv

    .NOTES
    Planned Updates:
        Allow for and handle multiple license input.
        Allow for license assignment without removing a license.
        Allow for license removal without applying a replacement license.

    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param (
        [Parameter(Mandatory)]
        [string]$LicenseToAdd,

        [Parameter(Mandatory)]
        [string]$LicenseToRemove,

        [Parameter()]
        [string]$LogPath = [Environment]::GetFolderPath("Desktop"),

        [string]$FileName = "LicenseMigrationLog.csv"
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    # Validate environment
    Test-OcmsModule -Module PowerShell -Version 7 -ThrowOnFail $true
    Test-OcmsModule -Module PnP
    Test-OcmsConnection -Service PnP
    Test-OcmsConnectoin -Service Graph

    # Define logging class
    class LicenseChangeMatrix {
        [string] ${Date}
        [string] ${Time}
        [string] ${UserUPN}
        [string] ${OriginalLicense}
        [string] ${NewLicense}
        [string] ${Errors}

        LicenseChangeMatrix(
            [string]$Date,
            [string]$Time, 
            [string]$UserUPN,          
            [string]$OriginalLicense, 
            [string]$NewLicense, 
            [string]$Errors) 

            {
                $this.Date = $Date
                $this.Time = $Time
                $this.UserUPN = $UserUPN
                $this.OriginalLicense = $OriginalLicense
                $this.NewLicense = $NewLicense
                $this.Errors = $Errors
            }
    }

    # Use List for efficiency
    $LicenseChangeIndex = [System.Collections.Generic.List[LicenseChangeMatrix]]::new()

    # Resolve SKU IDs
    $RemoveLicenseSku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $LicenseToRemove
    $AddLicenseSku    = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $LicenseToAdd

    # Get users with the license to remove
    $Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($RemoveLicenseSku.SkuId))" -ConsistencyLevel eventual -All

    Write-Verbose -ForegroundColor Cyan "Found $($Users.Count) users with $LicenseToRemove."

    foreach ($User in $Users) {
        $Upn = $User.UserPrincipalName
        $XError = ""

        if ($PSCmdlet.ShouldProcess("User $Upn", "Replace $LicenseToRemove with $LicenseToAdd")) {
            try {
                Set-MgUserLicense -UserId $Upn -AddLicenses @{SkuId = $AddLicenseSku.SkuId} -RemoveLicenses @($RemoveLicenseSku.SkuId)
                Write-Verbose -ForegroundColor Green "Updated $Upn from $LicenseToRemove to $LicenseToAdd"
            } 
                catch {
                   $XError = "Couldn't replace $Upn's $LicenseToRemove with $LicenseToAdd"
                  Write-Error -ForegroundColor Red $XError
            }
        } 

        else {
            Write-Host -ForegroundColor Yellow "WhatIf: $Upn would have been updated from $LicenseToRemove to $LicenseToAdd"
        }

        # Create and add object to the list
        $Object = [LicenseChangeMatrix]::new(
            (Get-Date -Format "MM/dd/yyyy"),
            (Get-Date -Format "HH:mm"),
            $Upn,
            $LicenseToRemove,
            $LicenseToAdd,
            $XError
        )

        $LicenseChangeIndex.Add($Object)
    }

    # Export log
    Write-OcmsLog -Data $LicenseChangeIndex -Path $LogPath -FileName $FileName

    Write-Host -ForegroundColor Green "License migration complete."
}
