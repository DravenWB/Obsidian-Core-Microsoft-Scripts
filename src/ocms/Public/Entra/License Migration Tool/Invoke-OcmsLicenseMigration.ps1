function Invoke-OcmsLicenseMigration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory)]
        [string]$LicenseToAdd,

        [Parameter(Mandatory)]
        [string]$LicenseToRemove,

        [Parameter()]
        [string]$LogPath = (Join-Path $env:USERPROFILE "Desktop\LicenseMigrationLog.csv")
    )

    # Validate environment
    Test-OcmsModule -Module PowerShell -Version 7 -ThrowOnFail $true
    Test-OcmsModule -Module PnP
    Test-OcmsConnection -Service "PnP"
    Test-OcmsConnectoin -Service "Graph"

    # Define logging class
    class LicenseChangeMatrix {
        [string] ${Date}
        [string] ${Time}
        [string] ${UserUPN}
        [string] ${OriginalLicense}
        [string] ${NewLicense}
        [string] ${Errors}

        LicenseChangeMatrix([string]$Date, [string]$Time, [string]$UserUPN,
                            [string]$OriginalLicense, [string]$NewLicense, [string]$Errors) {
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
        $XError = ""  # Initialize per iteration

        if ($PSCmdlet.ShouldProcess("User $Upn", "Replace $LicenseToRemove with $LicenseToAdd")) {
            try {
                Set-MgUserLicense -UserId $Upn -AddLicenses @{SkuId = $AddLicenseSku.SkuId} -RemoveLicenses @($RemoveLicenseSku.SkuId)
                Write-Verbose -ForegroundColor Green "Updated $Upn from $LicenseToRemove to $LicenseToAdd"
            } catch {
                $XError = "Couldn't replace $Upn's $LicenseToRemove with $LicenseToAdd"
                Write-Error -ForegroundColor Red $XError
            }
        } else {
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
    try {
        $LicenseChangeIndex | Export-Csv -Path $LogPath -NoClobber -Force
        Write-Verbose -ForegroundColor Green "Log exported to $LogPath"
    } catch {
        Write-Error -ForegroundColor Red "Failed to save CSV: $_"
    }
    Write-Host -ForegroundColor Green "All operations complete!"
}
