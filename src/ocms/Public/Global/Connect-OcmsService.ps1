function Connect-OcmsService {

    <#
    .SYNOPSIS
    Microsoft service connection tester.

    .DESCRIPTION
    Microsoft has too many connect commands that all differ for one reason or another. This module allows you to connect to SharePoint, Exchange, IPPS, Graph and PnP PowerShell services by using a single, standardized function call.
    
    .PARAMETER Service
    Select the service you want to connect to.
    Valid Options: SharePoint, Exchange, IPPS, Graph, PnP
    Defaults: None

    .PARAMETER TenantDomain
    Domain of the tenant you are connecting to. Ex: In contoso.onmicrosoft.com, the domain is "contoso".
    Defaults: None

    .PARAMETER Environment
    Type of environment you are connecting to.
    Valid Options: Commercial, GCCH, Germany, China
    Default: Commercial

    .PARAMETER AdminUPN
    UPN of the administrator connecting. In john.doe@contoso.com, the UPN is "john.doe".

    .EXAMPLE
    Connect-OcmsService -Service SharePoint -TenantDomain contoso -AdminUPN john.doe

    .EXAMPLE
    Connect-OcmsService -Service IPPS -TenantDomain contoso -Environment Germany -AdminUPN john.doe

    .EXAMPLE
    Connect-OcmsService -Service Exchange -TenantDomain contoso -Environment GCCH -AdminUPN john.doe


    .NOTES
    Planned Updates: Testing and run validation.

    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 07, 2025
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

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    switch($Environment)
        {
            'Commercial'{$TenantSuffix = ".com"; $TenantRegion = "Default"; $ExchangeConnectURI = "https://ps.compliance.protection.outlook.com/powershell-liveid/"}
            'GCCH' {$TenantSuffix = ".us"; $TenantRegion = "ITAR"; $ExchangeEnv = "O365USGovGCCHigh"; $ExchangeConnectURI = "https://ps.compliance.protection.office365.us/powershell-liveid/"}
            'Germany' {$TenantSuffix = ".de"; $TenantRegion = "Germany"; $ExchangeEnv = "O365GermanyCloud"; $ExchangeConnectURI = "https://ps.compliance.protection.outlook.com/powershell-liveid/"}
            'China' {$TenantSuffix = ".cn"; $TenantRegion = "China"; $ExchangeEnv = "O365China"; $ExchangeConnectURI = "https://ps.compliance.protection.partner.outlook.cn/powershell-liveid"}
            default {throw "Unknown Environment: $Environment"}
        }

    try {
        switch ($Service) {
            'SharePoint' {Connect-SPOService -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Region $TenantRegion}

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

            'IPPS' {Connect-IPPSSession -UserPrincipalName "$AdminUPN@$Domain.onmicrosoft.$TenantSuffix" -ConnectionUri $ExchangeConnectURI}

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

            'PnP' {Connect-PnPOnline -Url "https://$TenantDomain-admin.sharepoint.$TenantSuffix" -Interactive}
        }
    }
        catch {throw "There were errors connecting to the $Environment $Service Service: $($_.Exception.Message)"}
}