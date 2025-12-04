function Rename-OcmsSpoPageUrl {
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

    param(
        [Parameter(Mandatory)]
        [string]$TenantId,

        [string]$OutputPath
    )

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
        $Context.Load($Site) #Call the context to load the site.
        $Context.ExecuteQuery

        #Get dynamicly generated, relative URL for comparison with SharePoint Page property.
        $SiteRefURL = ("/sites/" + ((Get-SPOSite -Identity "https://spocotest.sharepoint.com/sites/Testsite65").Url -split("/"))[-1] + "/" + "SitePages")

        #Get all pages that do not start with the relative site URL.
        $CurrentSitePages = Get-PnPListItem -List "Site Pages" | Where-Object {-Not $_.FieldValues.FileRef.StartsWith($SiteRefURL)}

        #For all pages that don't match and have broken navigation...
        foreach ($Page in $CurrentSitePages)
        {
            #Load the page context.
            $Context.Load($Page)
            $Context.ExecuteQuery

            #Set the page URL properties.
            [string]$FileLeafRef_New = $SiteRefURL + "/" + $Page.FileLeafRef

            #Set field values and trigger save under new version to allow for reversion if required.
            try {Set-PnPListItem -List $Page.FileLeafRef -Values @{"FileRef" = $FileLeafRef_New; "FileDirRef" = $SiteRefURL} -UpdateType Update}
                catch
                    {Write-Error "An error has occurred in configuring the new page properties: $_"}
        }
    }
}