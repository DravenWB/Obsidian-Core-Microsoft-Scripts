function Connect-OcmsService {

    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description.

    .PARAMETER Param1
    Parameter description

    .PARAMETER Param2
    Parameter2 description

    .EXAMPLE
    Example command usage.

    .NOTES
    Author: DravenWB (GitHub)
    Module:
    Last Updated:
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [ValidateSet("SharePoint", "Exchange", "IPPS", "Graph", "PnP", IgnoreCase = $False)]
        [string]$Service,

        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$TenantDomain,

        [Parameter()]
        [ValidateCount(1)]
        [ValidateSet("Commercial", "GCCH", "Germany", "China")]
        [string]$Environment = "Commercial",

        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$AdminUPN
    )

    switch($Environment)
        {
            'Commercial'{$TenantSuffix = ".com"; $TenantRegion = "Default"; $ExchangeConnectURI = "https://ps.compliance.protection.outlook.com/powershell-liveid/"}
            'GCCH' {$TenantSuffix = ".us"; $TenantRegion = "ITAR"; $ExchangeEnv = "O365USGovGCCHigh"; $ExchangeConnectURI = "https://ps.compliance.protection.office365.us/powershell-liveid/"}
            'Germany' {$TenantSuffix = ".de"; $TenantRegion = "Germany"; $ExchangeEnv = "O365GermanyCloud"; $ExchangeConnectURI = "https://ps.compliance.protection.outlook.com/powershell-liveid/"}
            'China' {$TenantSuffix = ".cn"; $TenantRegion = "China"; $ExchangeEnv = "O365China"; $ExchangeConnectURI = "https://ps.compliance.protection.partner.outlook.cn/powershell-liveid"}
            default {throw "Unknown Environment: $Environment"}
        }

    switch ($Service) {
        'SharePoint' {
            try {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Region $TenantRegion}
                catch {
                    try {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Credential "$AdminUPN@$Domain.onmicrosoft.$TenantSuffix" -Region $TenantRegion -UseSystemBrowser $true}
                        catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
                }
        }

        'Exchange' {
            if ($Environment -eq "Commercial") {
                try {Connect-ExchangeOnline -UserPrincipalName "$AdminUPN@$Domain.onmicrosoft.$TenantSuffix"}
                    catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
            }
            else {
                try {Connect-ExchangeOnline -UserPrincipalName "$AdminUPN@$Domain.onmicrosoft.$TenantSuffix" -ExchangeEnvironmentName $ExchangeEnv}
                    catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
            }
        }

        'IPPS' {
            try {Connect-IPPSSession -UserPrincipalName "$AdminUPN@$Domain.onmicrosoft.$TenantSuffix" -ConnectionUri $ExchangeConnectURI}
                catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
        }

        'Graph' {
            if ($Environment -eq "Commercial") {
                try {Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All -NoWelcome}
                    catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
            }
            else {
                try {Connect-MGgraph -Scopes User.ReadWrite.All, Organization.Read.All -Environment USGov -NoWelcome}
                    catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
            }
        }

        'PnP' {
            try {Connect-PnPOnline -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Interactive}
                catch {
                    try {Connect-PnPOnline -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -OSLogin}
                        catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
                }
        }
    }
}