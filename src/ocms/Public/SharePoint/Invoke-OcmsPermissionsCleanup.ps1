function Invoke-OcmsPermissionsCleanup {
    <#
    .SYNOPSIS
    Admin permissions cleaner.

    .DESCRIPTION
    Removes an admin as a site collection administrator from all sites that they do not own.

    .PARAMETER Param1
    Parameter description

    .PARAMETER Param2
    Parameter2 description

    .EXAMPLE
    Example command usage.

    .NOTES
    Planned Updates:
        Cleanup and finish implementing parameters.
        Expand functionality.
        Implement logging.
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 06, 2025
    #>

    param()

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    Test-OcmsSpoConnection

    #Get the admin UPN.
    Write-Host "Please enter your SharePoint Administrator email for connection and temporary permissions assignment."
    Write-Host "Commercial Example: UPN@tenant.com"
    Write-Host " "
    $SharePointAdminUPN = Read-Host "Email"

    class OperationData {
        [int]    $Index
        [string] $Date
        [string] $Time
        [string] $Location
        [bool]   $SiteCollectionAdmin
        [bool]   $IsSiteOwner
        [string] $RemovedAsAdmin
        [string] $XErrors  
    }

    ####################################################################################################################################################################################

    Write-Host "Now reviewing all SharePoint sites for administrator and ownership settings..."
    Start-Sleep -Seconds 2

    #Get all sites and assign to variable.
    $SiteDirectory = Get-SPOSite -Limit All -IncludePersonalSite $true

    #Initialize the index counter.
    $IndexCounter = 0

    #Filter through every site and check if the operator is an administrator / owner.
    foreach ($Site in $SiteDirectory) {
        #Display progress bar for admin/owner checks.
        $ProgressPercent = ($IndexCounter / $SiteDirectory.Count) * 100
        $ProgressPercent = $ProgressPercent.ToString("#.##")
        Write-Progress -Activity "Setting Site Admin Permissions..." -Status "$ProgressPercent% Complete:" -PercentComplete $ProgressPercent

        #Check if user is part of the site.
        try {
            Get-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN
            $Run = $true
        }
            catch {$Run = $false}

        #Check if operator is part of the site.
        if ($Run) {
            #Get user data for site.
            $User = Get-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN

            #Get site owner group name(s).
            if ($User.Groups -notcontains (Get-SPOSiteGroup -Site $Site.Url | Where-Object {$_.Roles -contains "Full Control"}).Title) {
                Set-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN -IsSiteCollectionAdmin $false
            }
        }
    }
}
