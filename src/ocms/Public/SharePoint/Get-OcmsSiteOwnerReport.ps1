function Get-OcmsSiteOwnerReport {
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
    $SiteIndexData= @()

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

            $SiteIndexData += $Object
        }

    }

    $SiteIndexData | Export-Csv ~/Desktop/$FileName.csv -Encoding utf8
}