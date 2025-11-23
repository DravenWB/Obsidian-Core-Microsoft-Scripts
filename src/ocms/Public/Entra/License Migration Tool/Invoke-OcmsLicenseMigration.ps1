function Invoke-OcmsLicenseMigration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory)]
        [string]$LicenseToAdd,

        [Parameter(Mandatory)]
        [string]$LicenseToRemove,

        [Parameter(Mandatory)]
        [string]$LogPath
    )

    # Validate environment
    Test-OcmsPSVersion -Version 7 -ThrowOnFail $true
    Test-OcmsModuleInstallation -Module PnP
    Test-OcmsConnection -Service "PnP"
    Test-OcmsConnectoin -Service "Graph"

    $LicenseChangeIndex = @()

    # Object for logging
    class LicenseChangeMatrix {
        [string] ${Date}
        [string] ${Time}
        [string] ${UserUPN}
        [string] ${OriginalLicense}
        [string] ${NewLicense}
        [string] ${Errors}
    }

    # Resolve SKU IDs
    $RemoveLicenseSku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $LicenseToRemove
    $AddLicenseSku    = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $LicenseToAdd

    # Get users with the license to remove
    $Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($RemoveLicenseSku.SkuId))" -ConsistencyLevel eventual -All

    Write-Host -ForegroundColor Cyan "Found $($Users.Count) users with $LicenseToRemove."

    foreach ($User in $Users) {
        $Upn = $User.UserPrincipalName
        $XError = " "

        if ($PSCmdlet.ShouldProcess("User $Upn", "Replace $LicenseToRemove with $LicenseToAdd")) {
            try {
                Set-MgUserLicense -UserId $Upn -AddLicenses @{SkuId = $AddLicenseSku.SkuId} -RemoveLicenses @($RemoveLicenseSku.SkuId)
                Write-Host -ForegroundColor Green "Updated $Upn from $LicenseToRemove to $LicenseToAdd"
            } catch {
                $XError = "Couldn't replace $Upn's $LicenseToRemove with $LicenseToAdd"
                Write-Host -ForegroundColor Red $XError
            }
        } else {
            Write-Host -ForegroundColor Yellow "WhatIf: $Upn would have been updated from $LicenseToRemove to $LicenseToAdd"
        }

        # Log each change/error
        $Object = [LicenseChangeMatrix]@{
            Date           = Get-Date -Format "MM/dd/yyyy"
            Time           = Get-Date -Format "HH:mm"
            UserUPN        = $Upn
            OriginalLicense = $LicenseToRemove
            NewLicense      = $LicenseToAdd
            Errors         = $XError
        }

        $LicenseChangeIndex += $Object
    }

    # Export log
    try {
        $LicenseChangeIndex | Export-Csv -Path $LogPath -NoClobber -Force
        Write-Host -ForegroundColor Green "Log exported to $LogPath"
    } catch {
        Write-Host -ForegroundColor Red "Failed to save CSV: $_"
    }

    Write-Host -ForegroundColor Green "All operations complete!"
}
