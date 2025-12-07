function Get-OcmsSiteOwnerReport {
    <#
    .SYNOPSIS
    Get report of tenant site owners.

    .DESCRIPTION
    Gathers a report of every site owner, for every site in the entire tenant. Expands upon existing MS functionality that only returns the main site collection owner and not the rest.

    .PARAMETER FileName
    The name of the file to log the report to.
    Default: SiteOwnerReport.csv

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
        [string]$FileName = "SiteOwnerReport.csv"
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    #Custom function to test spo connection status.
    Test-OcmsSpoConnection

    #Gather all sites within the tenant.
    $SiteIndex = Get-SPOSite -limit ALL

    #Generate object class to store .csv data.
    class TableData
    {
        [string] ${SiteURL}
        [string] ${User}
    }

    #Generate array to store data.
    $SiteIndexData = [System.Collections.Generic.List]::new()

    #Loop to navigate each site and gather ALL owners assigned to each site.
    foreach ($Site in $SiteIndex)
    {
        #Set Site title variable for default groups.
        $SiteTitle = $Site.Title

        #Get owners and add them to the site data index.
        $SiteOwners = Get-SPOUser -Site $Site.Url -Group "$SiteTitle Owners" #Gets all owners on the individual site.

        foreach($Item in $SiteOwners) #Loops through each owner on the site and adds the object
        {
            $Object = New-Object PSObject -Property @{
            SiteURL = $Site.Url
            User = $Item.LoginName
            }

            $SiteIndexData.Add($Object)
        }
    }

    Write-OcmsLog -Object $SiteIndexData -FileName $FileName
}