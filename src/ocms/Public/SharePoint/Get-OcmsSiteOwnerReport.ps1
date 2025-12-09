function Get-OcmsSiteOwnerReport {
    <#
    .SYNOPSIS
    Get report of tenant site owners.

    .DESCRIPTION
    Gathers a report of every site owner, for every site in the entire tenant. Expands upon existing MS functionality that only returns the main site collection owner and not the rest.

    .PARAMETER FileName
    The name of the file to log the report to.
    Default: SiteOwnerReport.csv

    .PARAMETER LogPath
    The location the log file will be saved to.

    .EXAMPLE
    Get-OcmsSiteOwnerReport -FileName SiteOwnerReport.csv

    .NOTES
    Planned Updates: Ready for testing and debugging (if needed).
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param(
        [Parameter()]
        [ValidateCount(1)]
        [string]$FileName = "SiteOwnerReport.csv",

        [Parameter()]
        [ValidateCount(1)]
        [string]$LogPath = [Environment]::GetFolderPath("Desktop")
    )

    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    Test-OcmsSpoConnection

    class Data {
        [string] ${SiteURL}
        [string] ${User}

        Data(
            [string]$SiteURL
            [string]$User
        ){
            $this.SiteURL = $SiteURL
            $This.User = $User
        }
    }

    $SiteIndexData = [System.Collections.Generic.List]::new()

    $SiteIndex = Get-SPOSite -limit ALL

    foreach ($Site in $SiteIndex) {
        $SiteTitle = $Site.Title
        $SiteOwners = Get-SPOUser -Site $Site.Url -Group "$SiteTitle Owners"

        foreach($Item in $SiteOwners)
        {
            $Object = [Data]::new(
                ($Site.Url)
                ($Item.LoginName)
            )

            $SiteIndexData.Add($Object)
        }
    }
    Write-OcmsLog -Object $SiteIndexData -FileName $FileName -LogPath $LogPath
}