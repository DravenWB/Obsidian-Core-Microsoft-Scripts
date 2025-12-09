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

    .PARAMETER FileName
    The name of the log file to be saved.
    Default: PermissionsChangeReport.csv

    .PARAMETER LogPath
    The location the log file will be saved to.
    Default: User desktop.

    .EXAMPLE
    Invoke-OcmsPermissionsCleanup -AdminEmail john.doe@contoso.com

    .EXAMPLE
    Invoke-OcmsPermissionsCleanup -AdminEmail john.doe@contoso.com -FileName PermissionsChangeReport.csv -LogPath ~/Documents/Logs/

    .NOTES
    Planned Updates:
        Expand functionality.
        Testing and debugging (if required).
        
    Author: DravenWB (GitHub)
    Module: OCMS PowerShell
    Last Updated: December 09, 2025
    #>

    param(
        [Parameter(Mandatory)]
        [ValidateCount(1)]
        [string]$AdminEmail

        [Parameter()]
        [ValidateCount(1)]
        [string]$FileName = "PermissionsChangeReport.csv",

        [Parameter()]
        [ValidateCount(1)]
        [string]$LogPath = [Environment]::GetFolderPath("Desktop")
    )

    # Review and testing is necessary before anyone should even attempt to use this.
    throw "This function is not ready for use at this time. Additional changes, review and testing required."

    Test-OcmsSpoConnection

    class Data {
        [string] ${Date}
        [string] ${Time}
        [string] ${Location}
        [bool]   ${SiteCollectionAdmin}
        [bool]   ${IsSiteOwner}
        [string] ${RemovedAsAdmin}

        Data(
            [string] $Date
            [string] $Time
            [string] $Location
            [bool]   $SiteCollectionAdmin
            [bool]   $IsSiteOwner
            [string] $RemovedAsAdmin
        ){
            $this.Date = $Date
            $this.Time = $Time
            $this.Location = $Location
            $this.SiteCollectionAdmin = $SiteCollectionAdmin
            $this.IsSiteOwner = $IsSiteOwner
            $this.RemovedAsAdmin = $RemovedAsAdmin
        }
    }

    $PermissionsChangeData = [System.Collections.Generic.List[Data]]::new()

    ####################################################################################################################################################################################

    Write-Host "Now reviewing all SharePoint sites for administrator and ownership settings..."
    Start-Sleep -Seconds 2

    $SiteDirectory = Get-SPOSite -Limit All -IncludePersonalSite $true
    $IndexCounter = 0

    #Filter through every site and check if the operator is an administrator / owner.
    foreach ($Site in $SiteDirectory) {
        #Check if user is part of the site.
        try {
            Get-SPOUser -Site $Site.Url -LoginName $AdminEmail | null
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
                
                $UserIsOwner = $true
                $RemovedAsAdmin = $true
            }

            else {
                $UserIsOwner = $false
                $RemovedAsAdmin = $false
            }
        }

        $Object = [Data]::new(
            (Get-Date -Format "MM/dd/yyy")
            (Get-Date -Format "HH mm")
            $Site.Url
            $User.IsSiteCollectionAdmin
            $UserIsOwner
            $RemovedAsAdmin
        )

        $PermissionsChangeData.Add($Object)
    }

    Write-OcmsLog -Data $PermissionsChangeData -FileName $FileName -LogPath $LogPath
}
