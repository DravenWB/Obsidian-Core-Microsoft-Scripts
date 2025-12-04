Repair-OcmsGrouplessTeamsSites {
    [CmdletBinding()]

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

    param (
        [ValidateCount(1)]
        [Parameter()]
        [String]$LogPath = [Environment]::GetFolderPath("Desktop"),

        [ValidateCoun(1)]
        [Parameter()]
        [string]$FileName = "OcmsGroupRepair.csv"
    )

    Test-OcmsPSVersion -Version 5.2
    Test-OcmsSpoConnection

    Write-Verbose "Now gathering available tenant sites for processing..."

    #Gathers all sites in the tenant without an M365 Group ID.
    try{
        $SiteDirectory = Get-SPOSite -Limit All | Where-Object {$_.GroupId -eq "00000000-0000-0000-0000-000000000000" -or $_.GroupId -eq ""}
        Write-Verbose -ForegroundColor Green "Successfully gathered SharePoint site information!"
    }
        catch{throw "There was an error gathering the required site data: $($_.Exception.Message)"}

    #Initialize processing counter.
    $ProcessingCounter = 0
    $TotalItems = $SiteDirectory.Count()
    $ReversionIndex = @() #Variable to contain sites that the operator was not originally a site collection administrator of for later reversion.
    $ErrorRecord = @() #Index to record errors for later review.

    foreach($Site in $SiteDirectory) {
        $PercentComplete = ($ProcessingCounter/$TotalItems) * 100
        Write-Progress -Activity "Configuring private M365 Groups..." -Status "$ProcessingCounter out of $SiteDirectory completed." -PercentComplete $PercentComplete

        try {Get-SPOUser -Site $Site.Url -LoginName $AdminUPN | Out-Null}
            catch {
                $ReversionIndex.Add($Site)
                Set-SPOUser -Site $Site.Url -LoginName $AdminUPN -IsSiteCollectionAdmin $true | Out-Null
            }

        try {
            $Title = $Site.Title
            Set-SPOSiteOffice365Group -Site $Site.Url -DisplayName $Title -Description "Regenerated group for site collection $Title" -Alias $Title | Out-Null

            Write-Verbose -ForegroundColor Green "$Title successfully associated with M365 Private group."
        }
            catch {
                Write-Host -ForegroundColor Yellow "An error occurred while creating the group. Now attempting to modify M365 group title."

                try {
                    $ModTitle = $Title += "-Mod"
                    Set-SPOSiteOffice365Group -Site $Site.Url -DisplayName $ModTitle -Description "Regenerated group for site collection $Title" -Alias $ModTitle
                }
                    catch {
                        $SiteURLCurrent = $Site.Url
                        $XError = "Error: Second attempt to associate M365 Private group failed for $Title ($SiteURLCurrent)."
                        Write-Host -ForegroundColor Red $XError
                        $ErrorRecord.Add($XError)
                    }
            }
    }

    foreach ($Site in $ReversionIndex)
        {Set-SPOUser -Site $Site -LoginName $AdminUPN -IsSiteCollectionAdmin $false}
}