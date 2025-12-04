function Test-OcmsConnection {

    <#
    .SYNOPSIS
    Tests the connection of multiple services as a bootstrap utility.

    .DESCRIPTION
    Validates connectivity to SharePoint, Exchange, IPPS (Information Protection & Policy Service), Microsoft Graph, and PnP PowerShell. This function is typically used as a bootstrap check before running larger scripts or modules that depend on these connections.

    The function accepts multiple service names and consolidates all failures. By default, the function throws on any connection failure so that parent scripts can exit early.

    .PARAMETER Service
    The service being tested.
    Valid Values: SharePoint, Exchange, IPPS, Graph, PnP

    .PARAMETER ThrowOnFail
    Controls whether the function throws on failure.  
    Defaults to True.  
    Set to False to allow parent functions to continue even if one or more connections fail.

    .EXAMPLE
    Test-OcmsConnection -Service SharePoint

    .EXAMPLE
    Test-OcmsConnection -Service SharePoint, Exchange, IPPS

    .EXAMPLE
    Test-OcmsConnection -Service SharePoint -ThrowOnFail $false

    .NOTES
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 04, 2025
    #>

    $Failures = [System.Collections.Generic.List[object]]::new()

    [CmdletBinding()]
    param (
        [ValidateCount(1,5)]
        [ValidateSet('SharePoint', 'Exchange', 'IPPS', 'Graph', 'PnP')]
        [Parameter(Mandatory)]
        [String[]]$Service,

        [ValidateCount(1)]
        [Parameter()]
        [Boolean]$ThrowOnFail = $true
    )

    foreach ($Item in $Service) {
        try {
            switch ($Item) {
                'SharePoint' {Get-SPOTenant -ErrorAction Stop | Out-Null}
                'Exchange'   {Get-OrganizationConfig -ErrorAction Stop | Out-Null}
                'IPPS'       {Get-OMEConfiguration -ErrorAction Stop | Out-Null}
                'Graph'      {Get-MgEnvironment Name AzureADEndpoint GraphEndpoint Type | Out-Null}
                'PnP'        {Get-PnPConnection -ErrorAction Stop | Out-Null}
            }

            Write-Verbose "$Item confirmed connected."
        }
        catch {
            $Failures.Add([pscustomobject]@{
                Service = $Item
                Error   = $_.Exception.Message
            })
        }
    }

    if ($Failures.Count -gt 0) {
        foreach ($Entry in $Failures) {
            Write-Error "Connection test for service '$($Entry.Service)' failed: $($Entry.Error)"
        }

        if ($ThrowOnFail) {throw "Connection test failed for: $($Failures.Service -join ', ')"}
            else {Write-Verbose "Proceeding due to false ThrowOnFail flag."}
    }
}