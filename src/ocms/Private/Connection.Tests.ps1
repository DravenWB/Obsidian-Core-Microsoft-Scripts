Test-OcmsConnection {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [ValidateSet("SharePoint", "Graph", "PnP")]
        [Parameter(Mandatory)]
        [String]$Service
    )

    switch($Service) {
        'SharePoint' {
            try {
                Get-SPOTenant -ErrorAction Stop | Out-Null

                Write-Verbose "$Service confirmed connected."

                return $true
            }
                catch {
                    Write-Verbose "$Service disconnected. Please connect using Connect-OcmsService."
                    return $false
                }
        }

        'Graph' {
            $MGConnection = $null

            try {
                Get-MgEnvironment Name AzureADEndpoint GraphEndpoint Type | Out-Null

                Write-Verbose "$Service confirmed connected."

                return $true
            }
                catch {
                    Write-Verbose "$Service disconnected. Please connect using Connect-OcmsService."
                    return $false
                }
        }
        'PnP' {
            try {
                Get-PnPConnection -ErrorAction Stop | Out-Null

                Write-Verbose "$Service confirmed connected."

                return $true
            }
                catch {
                    Write-Verbose "$Service disconnected. Please connect using Connect-OcmsService."
                    return $false
                }
        }
    }
}