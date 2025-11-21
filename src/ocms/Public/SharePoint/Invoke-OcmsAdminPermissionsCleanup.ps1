####################################################################################################################################################################################
# Description: This script is designed to remove an administrator from all sites that they do not own. This is mostly helpful in scenarios in which an individual has become
#              the SharePoint site admin for a large list of sites.
#
# Development Date: December 13, 2023
#
####################################################################################################################################################################################
#Get operator details.

Write-Host "Now gathering variables required to run the script..."
Start-Sleep -Seconds 1

Write-Host " "

#Get the admin center URL.
Write-Host "Please enter the URL for your SharePoint Admin Center for connecting."
Write-Host "Ex: https://contoso-admin.sharepoint.com"
Write-Host " "
$SharePointAdminURL = Read-Host "URL"

Write-Host " "

#Get the admin UPN.
Write-Host "Please enter your SharePoint Administrator email for connection and temporary permissions assignment."
Write-Host "Commercial Example: UPN@tenant.com"
Write-Host " "
$SharePointAdminUPN = Read-Host "Email"

Write-Host " "

####################################################################################################################################################################################

class OperationData
{
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
foreach ($Site in $SiteDirectory)
    {
        #Display progress bar for admin/owner checks.
        $ProgressPercent = ($IndexCounter / $SiteDirectory.Count) * 100
        $ProgressPercent = $ProgressPercent.ToString("#.##")
        Write-Progress -Activity "Setting Site Admin Permissions..." -Status "$ProgressPercent% Complete:" -PercentComplete $ProgressPercent

        #Check if user is part of the site.
        try
            {
                Get-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN
                $Run = $true
            }

            catch {$Run = $false}

        #Check if operator is part of the site.
        if ($Run)
            {
                #Get user data for site.
                $User = Get-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN

                #Get site owner group name(s).
                if ($User.Groups -notcontains (Get-SPOSiteGroup -Site $Site.Url | Where-Object {$_.Roles -contains "Full Control"}).Title)
                    {
                        Set-SPOUser -Site $Site.Url -LoginName $SharePointAdminUPN -IsSiteCollectionAdmin $false
                    }
            }
    }
