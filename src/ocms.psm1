#Dot sourcing order matters when functions rely on one-another.

# Dot-source private functions
. "$PSScriptRoot/Private/Connection.Tests.ps1"
. "$PSScriptRoot/Private/PS.Version.Tests.ps1"

# Dot-source public functions
. "$PSScriptRoot/Public/SharePoint.Connections.ps1"
. "$PSScriptRoot/Public/Core.Settings.ps1"
. "$PSScriptRoot/Public/Identity.Licenses.ps1"
. "$PSScriptRoot/Public/Purview.Labels.ps1"

Export-ModuleMember -Function `
    'Connect-OcmsSPO',
    'Connect-OcmsPnPOnline',
    'Initialize-OcmsProfile',
    'Get-OcmsSetting',
    'Invoke-OcmsLicenseMigration',
    'Get-OcmsSensitivityLabelPolicy',
    'Export-OcmsSensitivityLabelPolicyReport',
    'Reset-OcmsSpoLibraryInheritance',
    'Get-OcmsSiteOwnerReport'

