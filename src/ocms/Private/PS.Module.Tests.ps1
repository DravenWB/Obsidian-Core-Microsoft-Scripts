function Test-OcmsModule {
    [CmdletBinding()]
    param (
        [ValidateCount(1)]
        [Parameter()]
        [version]$Version,

        [ValidateCount(1)]
        [ValidateSet("PowerShell", "SharePoint", "Graph", "PnP", "Exchange", IgnoreCase = $false)]
        [Parameter()]
        [string]$Module,

        [Parameter()]
        [Boolean]$ThrowOnFail = $true,

        [Parameter()]
        [Boolean]$AutoInstall = $false
    )

    $ModuleName = $Module
    switch ($Module) {
        'SharePoint' {$ModuleName = "Microsoft.Online.SharePoint.PowerShell"}
        'Graph'      {$ModuleName = "Microsoft.Graph"}
        'PnP'        {$ModuleName = "PnP.PowerShell"}
        'Exchange'   {$ModuleName = "ExchangeOnlineManagement"}
    }

    if ($ModuleName -eq "PowerShell") {
        $InstalledVersion = $PSVersionTable.PSVersion

        if ($InstalledVersion -ge $Version) { 
            Write-Verbose "Version test pass. Required: $Version. Current: $InstalledVersion"
            return $true
        }
        elseif ($AutoInstall -eq $true) {
            try {
                winget install --id Microsoft.PowerShell --source winget
                Write-Host "PowerShell v7 installation completed. Please continue in updated version."
                return $false
            }
            catch {
                Write-Error "Failed to install PowerShell automatically: $($_.Exception.Message)"
                if ($ThrowOnFail) 
                    {throw $_}
                        else {return $false}
            }
        }
        elseif ($ThrowOnFail -eq $true) {
            throw "PowerShell function requires PowerShell v$Version. Running: v$InstalledVersion."
        }
        else {
            Write-Error "PowerShell function requires PowerShell v$Version. Running: v$InstalledVersion. Unexpected behavior may occur."
            return $false
        }
    }

    else {
        Write-Verbose "Now checking $ModuleName installation status."

        try {$found = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue} 
        
        catch {
            Write-Verbose "Get-Module threw: $($_.Exception.Message)"
            $found = $null
        }

        if ($found) {
            Write-Verbose "Required $ModuleName module is currently installed."
\
            $best = $found | Sort-Object -Property Version -Descending | Select-Object -First 1

            if ($best.Version -ge $Version) { return $true } 
                else {
                    Write-Verbose "Installed version $($best.Version) is less than required $Version."

                    if (-not $AutoInstall) {
                        if ($ThrowOnFail) {
                            throw "Required Module: $ModuleName version $Version required; found $($best.Version)." 
                        }
                            else {
                                Write-Error "Required Module: $ModuleName version $Version required; found $($best.Version). Continuing."
                                return $false 
                            }
                    }
                }
        }
        else {
            Write-Verbose "Module $ModuleName not found."
        }

        if ($AutoInstall -eq $true) {
            Write-Verbose "Auto-install enabled. Now installing missing module $ModuleName"
            try {
                Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop
                Import-Module -Name $ModuleName -ErrorAction Stop

                $after = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1

                if ($after -and $after.Version -ge $Version) { return $true }
                    else {
                        if ($ThrowOnFail) { throw "$ModuleName installed but does not meet version $Version." }
                            else { Write-Error "$ModuleName installed but does not meet version $Version."; return $false }
                    }
            }
            catch {throw "$ModuleName failed to install with error: $($_.Exception.Message)"}
        }
        elseif ($ThrowOnFail -eq $true) {
            throw "Required Module: $ModuleName is not currently installed."
        }
        elseif ($ThrowOnFail -eq $false) {
            Write-Error "Installation of $ModuleName failed. Continuing due to false ThrowOnFail flag. Unexpected behavior may occur."
            return $false
        }
        else {throw "Unhandled exception: $($_.Exception.Message)"}
    }
}