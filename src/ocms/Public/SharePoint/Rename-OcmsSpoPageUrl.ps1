function Rename-OcmsSpoPageUrl {
    <#
    .SYNOPSIS
    SharePoint page URL corrector.

    .DESCRIPTION
    Tailor made for a customer who had a botched SharePoint page migration.

    .PARAMETER Param1
    Parameter description

    .PARAMETER Param2
    Parameter2 description

    .EXAMPLE
    Example command usage.

    .NOTES
    Planned Updates:
        Complete refactor
        Replace manual interactions.
        Implement parameters.

    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param()

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    Test-OcmsPSVersion -Version 7
    Test-OcmsPnPInstall

    #Prompt the user to input required variables.
    Write-Host ""
    Write-Host "Please enter the URL of your SharePoint admin center:"
    Write-Host "Example: https://contoso-admin.sharepoint.com"
    Write-Host "Example: https://contoso-admin.sharepoint.us"
    Write-Host "NOTE: If the name contains spaces, ensure you place a quotation mark at the beginning and end to ensure accurate input."

    $AdminCenterURL = Read-Host "Admin Center URL"

    #Removes quotations if present.
    if ($AdminCenterURL.StartsWith('"') -or $AdminCenterURL.EndsWith('"'))
        {$AdminCenterURL = ($AdminCenterURL.Trim('"'))}

    #Ensure the URL is ended with a /
    if (-not $AdminCenterURL.EndsWith('/'))
        {$AdminCenterURL += '/'}

    #Connect to PnP Online and exit if it fails. If succeeds, get the context and proceed.
    Write-Host ""
    try {Connect-PnPOnline -Url $AdminCenterURL -UseWebLogin}
        catch {throw -ForegroundColor Red "There was an error connecting to PnP Online: $_"}

    #Get the context.
    $Context = Get-PnPContext

    Test-OcmsSpoConnection

    #Get the SharePoint sites for the entire tenant to conduct URL mismatch checks.
    $SiteDirectory = Get-SPOSite -Limit All

    #Process the site pages of every site to ensure the properties of that page matches the site it is located on.
    foreach ($Site in $SiteDirectory)
    {
        #Load the site context.
        $Context.Load($Site)
        $Context.ExecuteQuery()

        #Get dynamically generated, relative URL for comparison with SharePoint Page property.
        #Example result: /sites/SiteName/SitePages
        $SiteName = ($Site.Url -split "/")[-1]
        $SiteRefURL = "/sites/$SiteName/SitePages"

        #Get all pages that do not start with the relative site URL.
        $CurrentSitePages = Get-PnPListItem -List "Site Pages" |
            Where-Object { -Not $_.FieldValues.FileRef.StartsWith($SiteRefURL) }

        #For all pages that don't match and have broken navigation...
        foreach ($Page in $CurrentSitePages)
        {
            #Load the page context.
            $Context.Load($Page)
            $Context.ExecuteQuery()

            #Set the page URL properties.
            [string]$FileLeafRef_New = $SiteRefURL + "/" + $Page.FieldValues.FileLeafRef

            #Set field values and trigger save under new version to allow for reversion if required.
            try {
                Set-PnPListItem -List "Site Pages" -Identity $Page.Id -Values @{
                    "FileRef"   = $FileLeafRef_New
                    "FileDirRef" = $SiteRefURL
                } -UpdateType Update
            }
            catch {
                Write-Error "An error has occurred in configuring the new page properties: $_"
            }
        }
    }
}