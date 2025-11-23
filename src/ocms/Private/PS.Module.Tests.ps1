
function Test-OcmsPSVersion {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [Parameter(Mandatory)]
        [version]$Version,

        [ValidateCount(1)]
        [ValidateSet($true, $false)]
        [Parameter()]
        [boolean]$ThrowOnFail
    )

if($ThrowOnFail -eq $null) {
    $ThrowOnFail = $true
}

$InstalledVersion = ($PSVersionTable.PSVersion)

Write-Verbose "Now checking PS version."

if ($InstalledVersion -ge '$Version') { 
    Write-Verbose "Version test pass. Required: $Version. Current: $InstalledVersion"
    return
}
    else {
        if ($ThrowOnFail == $true) {
            throw "Powershell function requires PowerShell v$Version. Running: v$InstalledVersion."
        }
            else {
                Write-Error "Powershell function requires PowerShell v$Version. Running: v$InstalledVersion. Unexpected behavior may occur."
                continue
            }
    }
}

function Test-OcmsModuleInstallation {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [ValidateSet("Sharepoint", "Graph", "PnP", IgnoreCase = $false)]
        [Parameter(Mandatory)]
        [string]$Module,

        [ValidateCount(1)]
        [ValidateSet($true, $false)]
        [Parameter()]
        [Boolean]$AutoInstall
    )

    if ($AutoInstall -eq $null) {
        $AutoInstall = $false
    }

Write-Verbose "Now checking if $Module is installed."

    try {
        Get-Module -ListAvailable -Name $Module
        Write-Verbose "Required $Module module is currently installed."
        continue
    }
        catch {
            if ($AutoInstall -eq $true) {
                Write-Verbose "Auto-install enabled. Now installing missing module $Module"

                try {
                    Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
                    continue
                }
                    catch {
                        throw "$Module failed to install with error: $_"
                    }

            else {
                throw "Required Module: $Module is not currently installed."
            }
            }
        }
}
