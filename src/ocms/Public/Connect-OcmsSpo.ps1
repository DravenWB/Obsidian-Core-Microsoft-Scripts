function Connect-OcmsSPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantDomain,

        [Parameter]
        [ValidateSet('Commercial', 'GCCH', 'Germany', 'China')]
        [string]$Environment,

        [Parameter]
        [string]$AdminUPN
    )

    if (-not $Environment) {$Environment = 'Commercial'}

    switch($Environment)
        {
            'Commercial'{$TenantSuffix = ".com"; $TenantRegion = "Default"}
            'GCCH' {$TenantSuffix = ".us"; $TenantRegion = "ITAR"}
            'Germany' {$TenantSuffix = ".de"; $TenantRegion = "Germany"}
            'China' {$TenantSuffix = ".cn"; $TenantRegion = "China"}
            default {throw "Unknown Environment: $Environment"}
        }

    try {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Region $TenantRegion}
        catch {
            try {
                Write-Error: "There were errors connecting to the $Environment SPO Service: $_"
                Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Credential $AdminUPN -Region $TenantRegion -UseSystemBrowser $true
            }
            catch {throw "There were errors connecting to the $Environment SPO Service: $_"}
        }
}
