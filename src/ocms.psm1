#Dot sourcing order matters when functions rely on one-another.

# Dot-source private functions
. "$PSScriptRoot/Private/Connection.Tests.ps1"
. "$PSScriptRoot/Private/PS.Module.Tests.ps1"
. "$PSSCriptRoot/Private/Write-OcmsLog.ps1"

# Dot-source public functions

  # Global
    . "$PSScriptRoot/Public/Global/Connect-OcmsService.ps1"
    . "$PSScriptRoot/Public/Global/Test-OcmsConnection.ps1"
    . "$PSScriptRoot/Public/Global/Test-OcmsModule.ps1"
    . "$PSScriptRoot/Public/Global/Write-OcmsLog.ps1"

  # Entra
    . "$PSScriptRoot/Public/Entra/Invoke-OcmsLicenseMigration.ps1"

  # Purview
    . "$PSScriptRoot/Public/Purview/Get-OcmsSensitivityLabelPolicy.ps1"

  # SharePoint
    . "$PSScriptRoot/Public/SharePoint/Get-OcmsSiteOwnerReport.ps1"
    . "$PSScriptRoot/Public/SharePoint/Invoke-OcmsPermissionsCleanup.ps1"
    . "$PSScriptRoot/Public/SharePoint/New-OcmsTestListItems.ps1"
    . "$PSScriptRoot/Public/SharePoint/Rename-OcmsSpoPageUrl.ps1"
    . "$PSScriptRoot/Public/SharePoint/Repair-OcmsGrouplessTeamSite.ps1"
    . "$PSScriptRoot/Public/SharePoint/Repair-OcmsUserPuid.ps1"
    . "$PSScriptRoot/Public/SharePoint/Reset-OcmsLibraryInheritance.ps1"

Export-ModuleMember -Function `

    # Global
    'Connect-OcmsService',
    'Test-OcmsConnection',
    'Test-OcmsModule',
    'Write-OcmsLog',

    #Entra
    'Invoke-OcmsLicenseMigration',

    #Purview
    'Get-OcmsSensitivityLabelPolicy',

    #SharePoint
    'Get-OcmsSiteOwnerReport',
    'Invoke-OcmsPermissionsCleanup',
    'New-OcmsTestListItems',
    'Rename-OcmsSpoPageUrl',
    'Repair-OcmsGrouplessTeamSite',
    'Repair-OcmsUserPuid',
    'Reset-OcmsLibraryInheritance'