function Write-OcmsLog {

    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description.

    .PARAMETER Param1
    Parameter description

    .PARAMETER Param2
    Parameter2 description

    .EXAMPLE
    Example command usage.

    .NOTES
    Author: DravenWB (GitHub)
    Module:
    Last Updated:
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Data,

        [ValidateCount(1)]
        [string]$FileName = "ocms-log",

        [ValidateCount(1)]
        [string]$LogPath = [Environment]::GetFolderPath("Desktop"),

        [ValidateCount(1)]
        [bool]$ThrowOnFail = $false
    )
}

$CompletePath = $LogPath + "\$FileName"

$LogModifier = Get-Date -Format "MM_dd_yyyy-HHmm"

Write-Verbose "Testing output to $CompletePath"

if (Test-Path $CompletePath) {
    try {
        Export-Csv -InputObject $Data -Path $CompletePath -NoClobber
        Write-Verbose "File at path already exists. Attempting modified file name."
    
        $CompletePath = $LogPath + "\$FileName" + "-$LogModifier"

        Write-Verbose "File save successful with modified file name."
    }
        catch {
            Write-Error "Unhandled exception: $($_.Exception.Message)"
            Write-Verbose "Attempting secondary alternative file name to output file."

            try {
                $BackupModifier = (Get-Date).Second
                $CompletePath = $LogPath + "\$FileName" + "-$LogModifier" + "-$BackupModifier"
                Export-Csv -InputObject $Data -Path $CompletePath -NoClobber

                Write-Verbose "Secondary file succeeded in save operation."
            }

            catch {
                if ($ThrowOnFail) {
                    throw "Unhandled exception: $($_.Exception.Message)"
                }
                else {Write-Error "Unhandled exception: $($_.Exception.Message)"} 
            }
        }
}

else {Export-Csv -InputObject $Data -Path $CompletePath -NoClobber}