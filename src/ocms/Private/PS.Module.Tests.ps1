
function Test-OcmsPSVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [version]$Version
    )

$InstalledVersion = ($PSVersionTable.PSVersion)

Write-Verbose "Now checking PS version."

if ($InstalledVersion -ge '$Version') { 

    Write-Verbose "Powershell version is $InstalledVersion and is greater than required version: $Version"
    return 
}

    else {
        Write-Error "The currently running PowerShell version is $InstalledVersion."
        Write-Error "This PowerShell script requires PowerShell version $Version or greater."
        throw "Please run in PowerShell $Version and try again."
    }
}

function Test-OcmsPnPInstall {
    [CmdletBinding()]
    param ()

    Write-Verbose "Now checking if PnP.PowerShell is installed."

    if (Get-Module -ListAvailable -Name 'PnP.PowerShell' -ErrorAction SilentlyContinue) {
        Write-Verbose "Required PnP.PowerShell module is currently installed."
        Return
    }

    else { throw "PnP.PowerShell is not installed. Please install the module to continue." }
}
