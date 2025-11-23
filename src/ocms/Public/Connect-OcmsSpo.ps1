function Connect-OcmsService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [ValidateSet("SharePoint", "Graph", "PnP", IgnoreCase = $False)]
        [string]$Service,

        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$TenantDomain,

        [Parameter()]
        [ValidateCount(1)]
        [ValidateSet('Commercial', 'GCCH', 'Germany', 'China')]
        [string]$Environment,

        [Parameter()]
        [ValidateCount(1)]
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

    switch ($Service) {
        'SharePoint' {
            try {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Region $TenantRegion}
                catch {
                    try {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Credential $AdminUPN -Region $TenantRegion -UseSystemBrowser $true}
                        catch {throw "There were errors connecting to the $Environment $Service Service: $_"}
                }
        }

        'Graph' {
            if ($Environment -eq "Commercial") {
                    try {Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -NoWelcome}
                        catch {throw "There were errors connecting to the $Environment $Service Service: $_"}
                }
                    else {
                        try {Connect-MGgraph -Scopes User.ReadWrite.All, Organization.Read.All -Environment USGov -NoWelcome}
                            catch {throw "There were errors connecting to the $Environment $Service Service: $_"}
                    }
        }

        'PnP' {
            try {Connect-PnPOnline -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Interactive}
                catch {
                    try {Connect-PnPOnline -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -OSLogin}
                        catch {throw "There were errors connecting to the $Environment $Service Service: $_"}
                }
        }
    }
}
