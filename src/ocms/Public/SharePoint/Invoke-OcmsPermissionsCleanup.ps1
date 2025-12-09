function Invoke-OcmsPermissionsCleanup {
    <#
    .SYNOPSIS
    Admin permissions cleaner.

    .DESCRIPTION
    Removes an admin as a site collection administrator from all sites that they do not own.

    .PARAMETER AdminEmail
    Email address of the administrator being checked against existing sites.
    Ex: john.doe@contoso.onmicrosoft.com
    Ex: john.doe@contoso.com

    .EXAMPLE
    Invoke-OcmsPermissionsCleanup -AdminEmail john.doe@contoso.com

    .NOTES
    Planned Updates:
        Expand functionality.
        Implement logging.
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 08, 2025
    #>

    param(
        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$AdminEmail
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    Test-OcmsSpoConnection

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
            Get-SPOUser -Site $Site.Url -LoginName $AdminEmail
            $UserOnSite = $true
        }
            catch {$UserOnSite = $false}

        #Check if operator is part of the site.
        if ($UserOnSite) {
            #Get user data for site.
            $User = Get-SPOUser -Site $Site.Url -LoginName $AdminEmail

            #Get site owner group name(s).
            if ($User.Groups -notcontains (Get-SPOSiteGroup -Site $Site.Url | Where-Object {$_.Roles -contains "Full Control"}).Title) {
                Set-SPOUser -Site $Site.Url -LoginName $AdminEmail -IsSiteCollectionAdmin $false
            }
        }
    }
}
