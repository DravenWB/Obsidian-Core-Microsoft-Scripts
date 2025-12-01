Test-OcmsConnection {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [ValidateSet("SharePoint", "Exchange", "IPPS", "Graph", "PnP")]
        [Parameter(Mandatory)]
        [String]$Service,

        [ValidateCount(1)]
        [Parameter()]
        [Boolean]$ThrowOnFail = $true
    )

    switch($Service) {
        'SharePoint' {
            try {
                Get-SPOTenant -ErrorAction Stop | Out-Null
                Write-Verbose "$Service confirmed connected."
                return $true
            }
            catch {
                if ($ThrowOnFail) {throw "$Service disconnected. Please connect using Connect-OcmsService."}
                    else {Write-Error "$Service disconnected. Errors may occur. ThrowOnFail set to false."}
            }
        }

        'Exchange' {
            try {
                Get-OrganizationConfig -ErrorAction Stop | Out-Null
                Write-Verbose "$Service confirmed connected."
                return $true
            }
            catch {
                if ($ThrowOnFail) {throw "$Service disconnected. Please connect using Connect-OcmsService."}
                    else {Write-Error "$Service disconnected. Errors may occur. ThrowOnFail set to false."}
            }
        }

        'IPPS' {
            try {
                Get-OMEConfiguration -ErrorAction Stop | Out-Null
                Write-Verbose "$Service confirmed connected."
                return $true
            }
            catch {
                if ($ThrowOnFail) {throw "$Service disconnected. Please connect using Connect-OcmsService."}
                    else {Write-Error "$Service disconnected. Errors may occur. ThrowOnFail set to false."}
            }
        }

        'Graph' {
            try {
                Get-MgEnvironment Name AzureADEndpoint GraphEndpoint Type | Out-Null
                Write-Verbose "$Service confirmed connected."
                return $true
            }
                catch {
                    if ($ThrowOnFail) {throw "$Service disconnected. Please connect using Connect-OcmsService."}
                        else {Write-Error "$Service disconnected. Errors may occur. ThrowOnFail set to false."}
                }
        }
        'PnP' {
            try {
                Get-PnPConnection -ErrorAction Stop | Out-Null
                Write-Verbose "$Service confirmed connected."
                return $true
            }
                catch {
                    if ($ThrowOnFail) {throw "$Service disconnected. Please connect using Connect-OcmsService."}
                        else {Write-Error "$Service disconnected. Errors may occur. ThrowOnFail set to false."}
                }
        }
    }
}