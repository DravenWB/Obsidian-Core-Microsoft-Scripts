
function Test-OcmsPSVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [version]$Version,

        [ValidateSet($true, $false, IgnoreCase = $true)]
        [boolean]$ThrowOnFail
    )

if($ThrowOnFail -eq $null) {$ThrowOnFail = $false}

$InstalledVersion = ($PSVersionTable.PSVersion)

Write-Verbose "Now checking PS version."

if ($InstalledVersion -ge '$Version') { Write-Verbose "Version test pass. Required: $Version. Current: $InstalledVersion"; return}
    else {
        if ($ThrowOnFail == $true) {throw "Powershell function requires PowerShell v$Version. Running: v$InstalledVersion."}
            else {Write-Error "Powershell function requires PowerShell v$Version. Running: v$InstalledVersion. Unexpected behavior may occur."; continue}
    }
}

function Test-OcmsPnPInstall {
    [CmdletBinding()]
    param ()

    Write-Verbose "Now checking if PnP.PowerShell is installed."

    if (Get-Module -ListAvailable -Name 'PnP.PowerShell' -ErrorAction SilentlyContinue) {Write-Verbose "Required PnP.PowerShell module is currently installed."; Return}
        else {throw "PnP.PowerShell is not installed. Please install the module to continue."}
}
